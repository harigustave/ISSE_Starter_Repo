#include <criterion/criterion.h>
#include <stddef.h>

#include "rbc/command.h"

Test(command, recognizes_supported_names)
{
    cr_assert_eq(rbc_command_from_name("add"), RBC_COMMAND_ADD);
    cr_assert_eq(rbc_command_from_name("sub"), RBC_COMMAND_SUB);
}

Test(command, rejects_unknown_name)
{
    cr_assert_eq(rbc_command_from_name("multiply"), RBC_COMMAND_INVALID);
    cr_assert_eq(rbc_command_from_name(NULL), RBC_COMMAND_INVALID);
}

Test(command, reports_printable_names)
{
    cr_assert_str_eq(rbc_command_name(RBC_COMMAND_ADD), "add");
    cr_assert_str_eq(rbc_command_name(RBC_COMMAND_SUB), "sub");
    cr_assert_str_eq(rbc_command_name(RBC_COMMAND_INVALID), "invalid");
}
