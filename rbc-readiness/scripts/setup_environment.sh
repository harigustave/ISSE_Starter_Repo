#!/bin/sh

set -u

MODE=check
case "$#" in
    0) MODE=check ;;
    1)
        case "$1" in
            --check) MODE=check ;;
            --install) MODE=install ;;
            --help)
                cat <<'HELP'
Usage:
  ./scripts/setup_environment.sh
  ./scripts/setup_environment.sh --check
  ./scripts/setup_environment.sh --install
  ./scripts/setup_environment.sh --help

--check (default)
  Check required development capabilities without changing the machine.

--install
  Use an already-configured supported package manager to install missing
  package-backed tools, then run the same checks. The script does not add
  package repositories or download remote installer scripts.

Environment policy
  * Linux/GitHub Codespaces is the course reference environment.
  * GCC, GNU Make, Git, Criterion, and common binary-inspection tools are
    required there.
  * Linux also requires GDB and Valgrind/Memcheck.
  * macOS can be used for ordinary local build/test work when the corresponding
    tools are available; use Linux/Codespaces for Linux-specific tools.
HELP
                exit 0
                ;;
            *)
                printf 'ERROR: unsupported argument: %s\n' "$1" >&2
                exit 2
                ;;
        esac
        ;;
    *)
        printf 'ERROR: expected zero arguments or one of --check, --install, --help.\n' >&2
        exit 2
        ;;
esac

have_command() {
    command -v "$1" >/dev/null 2>&1
}

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

pass() {
    printf 'PASS: %s\n' "$1"
    PASS_COUNT=$((PASS_COUNT + 1))
}

fail() {
    printf 'FAIL: %s\n' "$1"
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

warn() {
    printf 'WARN: %s\n' "$1"
    WARN_COUNT=$((WARN_COUNT + 1))
}

uname_s=$(uname -s 2>/dev/null || printf unknown)
case "$uname_s" in
    Linux)
        PLATFORM=linux
        CC_PROBE=gcc
        ;;
    Darwin)
        PLATFORM=macos
        if have_command clang; then
            CC_PROBE=clang
        else
            CC_PROBE=cc
        fi
        ;;
    *)
        printf 'ERROR: unsupported operating system: %s\n' "$uname_s" >&2
        exit 2
        ;;
esac

if [ "$MODE" = install ]; then
    if [ "$PLATFORM" = linux ]; then
        if ! have_command apt-get; then
            printf 'ERROR: --install requires apt-get on the supported Linux image.\n' >&2
            exit 3
        fi
        if [ "$(id -u)" -eq 0 ]; then
            APT_PREFIX=
        elif have_command sudo; then
            APT_PREFIX=sudo
        else
            printf 'ERROR: --install needs root or sudo for apt-get.\n' >&2
            exit 3
        fi
        # Intentional word splitting for optional sudo prefix.
        # shellcheck disable=SC2086
        $APT_PREFIX apt-get update
        # shellcheck disable=SC2086
        $APT_PREFIX apt-get install -y \
            build-essential git pkg-config libcriterion-dev \
            binutils file gdb valgrind
    else
        if ! have_command brew; then
            printf 'ERROR: --install on macOS requires an existing Homebrew installation.\n' >&2
            exit 3
        fi
        brew install criterion pkg-config
    fi
fi

probe_dir=$(mktemp -d "${TMPDIR:-/tmp}/rbc-readiness-env.XXXXXX") || exit 5
trap 'rm -rf "$probe_dir"' EXIT HUP INT TERM

WARN_FLAGS='-Wall -Wextra -Wpedantic -Wstrict-prototypes -Wmissing-prototypes'

cat >"$probe_dir/c17_probe.c" <<'C_EOF'
#include <stdio.h>

int main(void)
{
    puts("c17-ok");
    return 0;
}
C_EOF

# shellcheck disable=SC2086
if have_command "$CC_PROBE" \
    && "$CC_PROBE" -std=c17 $WARN_FLAGS -g3 -O0 \
        "$probe_dir/c17_probe.c" -o "$probe_dir/c17_probe" >/dev/null 2>&1 \
    && [ "$("$probe_dir/c17_probe" 2>/dev/null)" = c17-ok ]; then
    pass "$CC_PROBE C17 warning-clean compile/link/run"
else
    fail "$CC_PROBE C17 warning-clean compile/link/run"
fi

if have_command make && make --version 2>/dev/null | grep 'GNU Make' >/dev/null 2>&1; then
    pass 'GNU Make'
else
    fail 'GNU Make'
fi

if have_command git && git --version >/dev/null 2>&1; then
    pass 'Git'
else
    fail 'Git'
fi

criterion_cflags=""
criterion_libs="-lcriterion"
if have_command pkg-config && pkg-config --exists criterion >/dev/null 2>&1; then
    criterion_cflags=$(pkg-config --cflags criterion 2>/dev/null || printf '')
    criterion_libs=$(pkg-config --libs criterion 2>/dev/null || printf '')
    [ -n "$criterion_libs" ] || criterion_libs="-lcriterion"
fi

cat >"$probe_dir/criterion_probe.c" <<'C_EOF'
#include <criterion/criterion.h>

Test(readiness_environment, criterion_runs)
{
    cr_assert_eq(2 + 3, 5);
}
C_EOF

# Intentional word splitting for compiler/linker flag lists.
# shellcheck disable=SC2086
if have_command "$CC_PROBE" \
    && "$CC_PROBE" -std=c17 $WARN_FLAGS $criterion_cflags \
        "$probe_dir/criterion_probe.c" $criterion_libs \
        -o "$probe_dir/criterion_probe" >/dev/null 2>&1 \
    && "$probe_dir/criterion_probe" >/dev/null 2>&1; then
    pass 'Criterion compile/link/run'
else
    fail 'Criterion compile/link/run'
fi

cat >"$probe_dir/object_probe.c" <<'C_EOF'
int readiness_square(int value)
{
    return value * value;
}
C_EOF

# shellcheck disable=SC2086
if have_command "$CC_PROBE" \
    && "$CC_PROBE" -std=c17 $WARN_FLAGS -c \
        "$probe_dir/object_probe.c" -o "$probe_dir/object_probe.o" >/dev/null 2>&1; then
    pass 'compiler-produced relocatable object'

    if have_command file && file "$probe_dir/object_probe.o" >/dev/null 2>&1; then
        pass 'file object inspection'
    else
        fail 'file object inspection'
    fi

    if have_command nm && nm "$probe_dir/object_probe.o" >/dev/null 2>&1; then
        pass 'nm symbol inspection'
    else
        fail 'nm symbol inspection'
    fi

    if [ "$PLATFORM" = linux ]; then
        if have_command readelf && readelf -h "$probe_dir/object_probe.o" >/dev/null 2>&1; then
            pass 'readelf ELF inspection'
        else
            fail 'readelf ELF inspection'
        fi
        if have_command objdump && objdump -d "$probe_dir/object_probe.o" >/dev/null 2>&1; then
            pass 'objdump disassembly'
        else
            fail 'objdump disassembly'
        fi
    fi
else
    fail 'compiler-produced relocatable object'
fi

cat >"$probe_dir/sanitize_probe.c" <<'C_EOF'
#include <stdlib.h>

int main(void)
{
    int *value = malloc(sizeof(*value));
    if (value == NULL) {
        return 2;
    }
    *value = 7;
    free(value);
    return 0;
}
C_EOF

# shellcheck disable=SC2086
if have_command "$CC_PROBE" \
    && "$CC_PROBE" -std=c17 $WARN_FLAGS -g3 -O0 \
        -fsanitize=address,undefined -fno-omit-frame-pointer \
        "$probe_dir/sanitize_probe.c" -o "$probe_dir/sanitize_probe" >/dev/null 2>&1 \
    && ASAN_OPTIONS=detect_leaks=0:halt_on_error=1 \
        "$probe_dir/sanitize_probe" >/dev/null 2>&1; then
    pass 'ASan/UBSan clean compile/link/run'
else
    fail 'ASan/UBSan clean compile/link/run'
fi

if [ "$PLATFORM" = linux ]; then
    if have_command gdb \
        && gdb -q -batch -ex 'start' -ex 'continue' \
            --args "$probe_dir/c17_probe" >/dev/null 2>&1; then
        pass 'GDB can execute a debug build'
    else
        fail 'GDB can execute a debug build'
    fi

    cat >"$probe_dir/memcheck_probe.c" <<'C_EOF'
#include <stdlib.h>

int main(void)
{
    void *block = malloc(16);
    if (block == NULL) {
        return 2;
    }
    free(block);
    return 0;
}
C_EOF

    # shellcheck disable=SC2086
    if have_command valgrind \
        && "$CC_PROBE" -std=c17 $WARN_FLAGS -g3 -O0 \
            "$probe_dir/memcheck_probe.c" -o "$probe_dir/memcheck_probe" \
            >/dev/null 2>&1 \
        && valgrind --tool=memcheck --quiet --leak-check=full \
            --error-exitcode=99 "$probe_dir/memcheck_probe" >/dev/null 2>&1; then
        pass 'Valgrind/Memcheck clean execution'
    else
        fail 'Valgrind/Memcheck clean execution'
    fi
else
    warn 'GDB, Valgrind/Memcheck, and ELF-specific checks belong in Linux/Codespaces'
fi

printf '\nSummary: %d passed, %d failed, %d warning(s).\n' \
    "$PASS_COUNT" "$FAIL_COUNT" "$WARN_COUNT"

if [ "$FAIL_COUNT" -ne 0 ]; then
    printf 'NOT READY\n'
    exit 1
fi

printf 'READY\n'
exit 0
