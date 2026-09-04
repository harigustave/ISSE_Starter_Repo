#!/bin/sh

ok=1

pass() { printf 'PASS: %s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*"; }
fail() { printf 'FAIL: %s\n' "$*"; ok=0; }
info() { printf 'INFO: %s\n' "$*"; }

# Identify the operating system and architecture.
kernel=$(uname -s 2>/dev/null || printf 'unknown')
arch=$(uname -m 2>/dev/null || printf 'unknown')
os=unknown

if [ -r /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    os=${PRETTY_NAME:-unknown}
elif [ "$kernel" = "Darwin" ]; then
    os="macOS"
fi

is_wsl=0
if [ "$kernel" = "Linux" ] && [ -r /proc/version ]; then
    if grep -qi 'microsoft' /proc/version 2>/dev/null; then
        is_wsl=1
    fi
fi

info "$os; kernel $kernel; architecture $arch"

# Classify the environment.
if [ "$kernel" = "Linux" ] && [ "$is_wsl" -eq 0 ]; then
    case "$os:$arch" in
        *Ubuntu\ 24.04*:x86_64)
            pass "Ubuntu 24.04 LTS x86-64 — matches the course-supported reference environment"
            ;;
        *Ubuntu\ 24.04*:*)
            warn "Ubuntu 24.04 LTS on $arch may work, but the course-supported reference environment is Ubuntu 24.04 LTS x86-64"
            ;;
        *)
            warn "This Linux environment may work, but the course-supported reference environment is Ubuntu 24.04 LTS x86-64"
            ;;
    esac
elif [ "$kernel" = "Linux" ] && [ "$is_wsl" -eq 1 ]; then
    warn "Windows Subsystem for Linux (WSL) may work, but the course-supported reference environment is Ubuntu 24.04 LTS x86-64"
elif [ "$kernel" = "Darwin" ]; then
    warn "macOS may work, but the course-supported reference environment is Ubuntu 24.04 LTS x86-64"
else
    fail "unsupported operating system ($kernel); use Ubuntu 24.04 LTS x86-64 or a compatible Unix-like environment"
fi

check_tools() {
    group=$1
    shift
    info "$group"
    for tool in "$@"; do
        if command -v "$tool" >/dev/null 2>&1; then
            pass "found $tool"
        else
            fail "missing $tool"
        fi
    done
}

check_tools "Core build and repository tools" gcc make git sh
check_tools "Artifact-inspection tools" file od awk readelf objdump objcopy nm ldd

# Check the compiler.
if command -v gcc >/dev/null 2>&1; then
    gcc_id=$(gcc --version 2>/dev/null | sed -n '1p')

    case "$gcc_id" in
        gcc\ *|*GCC*)
            pass "GNU GCC detected — $gcc_id"
            ;;
        *clang*|*Clang*)
            warn "gcc invokes Clang rather than GNU GCC — $gcc_id; this may work, but GNU GCC is the course reference compiler"
            ;;
        *)
            warn "compiler behind 'gcc' is not identified as GNU GCC — $gcc_id; compatibility will be determined by the C17 probe"
            ;;
    esac

    if printf 'int main(void){return 0;}\n' \
        | gcc -std=c17 -Wall -Wextra -Wpedantic -x c -fsyntax-only - \
            >/dev/null 2>&1; then
        pass "C17 diagnostic probe"
    else
        fail "C17 diagnostic probe"
    fi
fi

# Check Make.
if command -v make >/dev/null 2>&1; then
    make_id=$(make --version 2>/dev/null | sed -n '1p')

    case "$make_id" in
        GNU\ Make*)
            pass "GNU Make detected — $make_id"
            ;;
        *)
            warn "make is not identified as GNU Make — $make_id; it may work for R01, but GNU Make is the course reference implementation"
            ;;
    esac
fi

if command -v git >/dev/null 2>&1; then
    info "$(git --version 2>/dev/null)"
fi

exit "$((1-ok))"
