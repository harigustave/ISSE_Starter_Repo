UNAME_S := $(shell uname -s)

ifeq ($(origin CC), default)
ifeq ($(UNAME_S),Darwin)
CC := clang
else
CC := gcc
endif
endif

PKG_CONFIG ?= pkg-config
CRITERION_CFLAGS := $(shell $(PKG_CONFIG) --cflags criterion 2>/dev/null)
CRITERION_LIBS := $(shell $(PKG_CONFIG) --libs criterion 2>/dev/null)
ifeq ($(strip $(CRITERION_LIBS)),)
CRITERION_LIBS := -lcriterion
endif

CPPFLAGS := -Iinclude
WARNINGS := -Wall -Wextra -Wpedantic -Wstrict-prototypes -Wmissing-prototypes
CFLAGS_COMMON := -std=c17 $(WARNINGS) -g3 -O0 -MMD -MP
TEST_CPPFLAGS := -Iinclude

PROD_SRCS := \
	src/command.c \
	src/operation.c \
	src/main.c

LIB_SRCS := \
	src/command.c \
	src/operation.c

UNIT_SRCS := \
	tests/unit/test_command.c \
	tests/unit/test_operation.c

NORMAL_OBJS := $(patsubst src/%.c,build/normal/obj/%.o,$(PROD_SRCS))
TEST_SRC_OBJS := $(patsubst src/%.c,build/test/obj/src/%.o,$(LIB_SRCS))
TEST_UNIT_OBJS := $(patsubst tests/unit/%.c,build/test/obj/unit/%.o,$(UNIT_SRCS))

NORMAL_BIN := build/normal/bin/rbc
TEST_BIN := build/test/bin/rbc_tests

ALL_DEPS := \
	$(NORMAL_OBJS:.o=.d) \
	$(TEST_SRC_OBJS:.o=.d) \
	$(TEST_UNIT_OBJS:.o=.d)

.PHONY: all test clean

all: $(NORMAL_BIN)

$(NORMAL_BIN): $(NORMAL_OBJS)
	@mkdir -p $(@D)
	$(CC) $(CFLAGS_COMMON) $^ -o $@

build/normal/obj/%.o: src/%.c
	@mkdir -p $(@D)
	$(CC) $(CPPFLAGS) $(CFLAGS_COMMON) -c $< -o $@

$(TEST_BIN): $(TEST_SRC_OBJS) $(TEST_UNIT_OBJS)
	@mkdir -p $(@D)
	$(CC) $(CFLAGS_COMMON) $^ $(CRITERION_LIBS) -o $@

build/test/obj/src/%.o: src/%.c
	@mkdir -p $(@D)
	$(CC) $(TEST_CPPFLAGS) $(CFLAGS_COMMON) -c $< -o $@

build/test/obj/unit/%.o: tests/unit/%.c
	@mkdir -p $(@D)
	$(CC) $(TEST_CPPFLAGS) $(CRITERION_CFLAGS) $(CFLAGS_COMMON) -c $< -o $@

test: $(TEST_BIN) $(NORMAL_BIN)
	$(TEST_BIN)
	tests/cli/test_cli.sh $(NORMAL_BIN)

clean:
	rm -rf build

-include $(ALL_DEPS)
