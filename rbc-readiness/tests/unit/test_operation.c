#include <criterion/criterion.h>

#include "rbc/command.h"
#include "rbc/operation.h"

Test(operation, adds_small_integers)
{
    cr_assert_eq(rbc_operation_apply(RBC_COMMAND_ADD, 2, 3), 5);
    cr_assert_eq(rbc_operation_apply(RBC_COMMAND_ADD, -4, 7), 3);
}

Test(operation, subtracts_small_integers)
{
    cr_assert_eq(rbc_operation_apply(RBC_COMMAND_SUB, 9, 4), 5);
    cr_assert_eq(rbc_operation_apply(RBC_COMMAND_SUB, -2, 3), -5);
}
