#include "rbc/operation.h"

#include <assert.h>

int rbc_operation_apply(enum rbc_command_kind kind, int left, int right)
{
    switch (kind) {
    case RBC_COMMAND_ADD:
        return left + right;
    case RBC_COMMAND_SUB:
        return left - right;
    case RBC_COMMAND_INVALID:
    default:
        assert(!"rbc_operation_apply requires a valid command");
        return 0;
    }
}
