#!/bin/sh

./program >/dev/null
status=$?
if [ "$status" -ne 0 ]; then
    printf 'FAIL: expected program exit status 0; observed %s.\n' "$status" >&2
    exit 1
fi

actual=$(./program; printf '__R01_END__')
expected='1
__R01_END__'
if [ "$actual" != "$expected" ]; then
    observed=$(./program)
    printf '%s\n' "FAIL: expected stdout 1\\n; observed value '$observed'." >&2
    exit 1
fi

printf 'PASS: program exits 0 and prints 1 followed by a newline.\n'
