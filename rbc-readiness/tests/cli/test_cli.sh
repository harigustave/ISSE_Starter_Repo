#!/bin/sh
set -eu

if [ "$#" -ne 1 ]; then
    echo "usage: test_cli.sh /path/to/rbc" >&2
    exit 2
fi

rbc=$1
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT HUP INT TERM

case_number=0

run_case() {
    case_number=$((case_number + 1))
    name=$1
    input=$2
    expected_stdout=$3
    expected_stderr=$4
    expected_status=$5

    printf '%b' "$input" >"$tmpdir/input"
    printf '%b' "$expected_stdout" >"$tmpdir/expected.out"
    printf '%b' "$expected_stderr" >"$tmpdir/expected.err"

    set +e
    "$rbc" <"$tmpdir/input" >"$tmpdir/actual.out" 2>"$tmpdir/actual.err"
    actual_status=$?
    set -e

    if [ "$actual_status" -ne "$expected_status" ] ||
       ! cmp -s "$tmpdir/expected.out" "$tmpdir/actual.out" ||
       ! cmp -s "$tmpdir/expected.err" "$tmpdir/actual.err"; then
        echo "CLI case $case_number ($name) failed" >&2
        echo "expected status: $expected_status; actual: $actual_status" >&2
        diff -u "$tmpdir/expected.out" "$tmpdir/actual.out" >&2 || true
        diff -u "$tmpdir/expected.err" "$tmpdir/actual.err" >&2 || true
        exit 1
    fi
}

run_case "single command" \
    'add 10 7\n' \
    '17\n' \
    '' \
    0

case_number=$((case_number + 1))
printf '5\n5\n' >"$tmpdir/expected.out"
printf '' >"$tmpdir/expected.err"
set +e
"$rbc" <"$script_dir/../fixtures/smoke.in" >"$tmpdir/actual.out" 2>"$tmpdir/actual.err"
actual_status=$?
set -e
if [ "$actual_status" -ne 0 ] ||
   ! cmp -s "$tmpdir/expected.out" "$tmpdir/actual.out" ||
   ! cmp -s "$tmpdir/expected.err" "$tmpdir/actual.err"; then
    echo "CLI case $case_number (fixture with two commands) failed" >&2
    echo "expected status: 0; actual: $actual_status" >&2
    diff -u "$tmpdir/expected.out" "$tmpdir/actual.out" >&2 || true
    diff -u "$tmpdir/expected.err" "$tmpdir/actual.err" >&2 || true
    exit 1
fi

run_case "unknown command" \
    'multiply 2 3\n' \
    '' \
    'rbc: invalid readiness command\n' \
    2

exit 0
