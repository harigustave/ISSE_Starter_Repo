#ifndef RBC_COMMAND_H
#define RBC_COMMAND_H

/* Commands accepted by the readiness program. */
enum rbc_command_kind {
    RBC_COMMAND_INVALID = 0,
    RBC_COMMAND_ADD,
    RBC_COMMAND_SUB
};

/* Return the command kind for a command word, or RBC_COMMAND_INVALID. */
enum rbc_command_kind rbc_command_from_name(const char *name);

/* Return a stable printable name for a valid command, or "invalid". */
const char *rbc_command_name(enum rbc_command_kind kind);

#endif
