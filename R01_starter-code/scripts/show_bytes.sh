#!/bin/sh

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    printf 'usage: %s FILE [MAX_BYTES]\n' "$0" >&2
    exit 2
fi

file=$1
limit=${2:-32}

case "$limit" in
    ''|*[!0-9]*)
        printf 'error: MAX_BYTES must be a nonnegative integer\n' >&2
        exit 2
        ;;
esac

if [ ! -r "$file" ]; then
    printf 'error: cannot read %s\n' "$file" >&2
    exit 1
fi

printf '%-8s %-4s %s\n' OFFSET HEX BINARY
od -An -v -t u1 -N "$limit" "$file" |
awk '
function bits8(n,    s, i) {
    s = ""
    for (i = 0; i < 8; i++) {
        s = (n % 2) s
        n = int(n / 2)
    }
    return s
}
{
    for (i = 1; i <= NF; i++) {
        n = $i + 0
        printf "%06x   %02x   %s\n", offset, n, bits8(n)
        offset++
    }
}'
