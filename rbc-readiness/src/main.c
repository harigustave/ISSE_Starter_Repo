#include "rbc/command.h"
#include "rbc/operation.h"
#include "internal/config.h"

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>

static int report_invalid_command(void)
{
    fputs("rbc: invalid readiness command\n", stderr);
    return 2;
}

static int parse_operand(const char *text, int *out_value)
{
    char *end = NULL;
    long value;

    errno = 0;
    value = strtol(text, &end, 10);
    if (errno == ERANGE || end == text || *end != '\0') {
        return 0;
    }
    if (value < RBC_READINESS_OPERAND_MIN || value > RBC_READINESS_OPERAND_MAX) {
        return 0;
    }

    *out_value = (int)value;
    return 1;
}

int main(int argc, char *argv[])
{
    char name[16];
    char left_text[64];
    char right_text[64];

    (void)argv;

    if (argc != 1) {
        fputs("usage: rbc\n", stderr);
        return 2;
    }

    for (;;) {
        int scanned = scanf("%15s %63s %63s", name, left_text, right_text);
        enum rbc_command_kind kind;
        int left;
        int right;

        if (scanned == EOF) {
            if (ferror(stdin)) {
                fputs("rbc: input error\n", stderr);
                return 2;
            }
            return 0;
        }
        if (scanned != 3) {
            return report_invalid_command();
        }

        kind = rbc_command_from_name(name);
        if (kind == RBC_COMMAND_INVALID ||
            !parse_operand(left_text, &left) ||
            !parse_operand(right_text, &right)) {
            return report_invalid_command();
        }

        printf("%d\n", rbc_operation_apply(kind, left, right));
    }
}
