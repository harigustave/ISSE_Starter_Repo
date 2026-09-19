#ifndef RBC_OPERATION_H
#define RBC_OPERATION_H

#include "rbc/command.h"

/*
 * Apply a valid readiness command.
 * Preconditions: kind is ADD or SUB and each operand is in [-1000, 1000].
 */
int rbc_operation_apply(enum rbc_command_kind kind, int left, int right);

#endif
