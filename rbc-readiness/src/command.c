#include "rbc/command.h"

#include <string.h>

enum rbc_command_kind rbc_command_from_name(const char *name)
{
    if (name == NULL) {
        return RBC_COMMAND_INVALID;
    }
    if (strcmp(name, "add") == 0) {
        return RBC_COMMAND_ADD;
    }
    if (strcmp(name, "sub") == 0) {
        return RBC_COMMAND_SUB;
    }
    return RBC_COMMAND_INVALID;
}

const char *rbc_command_name(enum rbc_command_kind kind)
{
    switch (kind) {
    case RBC_COMMAND_ADD:
        return "add";
    case RBC_COMMAND_SUB:
        return "sub";
    case RBC_COMMAND_INVALID:
    default:
        return "invalid";
    }
}
