This starter repository is intentionally small. You will use a tiny C program to explore how the course environment, GCC compilation pipeline, Make, tests, Git, and basic binary-inspection tools fit together.

# Objectives

You will use this repository to:

- work inside the course-supported **GitHub Codespace**;
- verify that the Linux/GCC toolchain is ready;
- compile C code one stage at a time;
- inspect preprocessed C, assembly, object files, and executables;
- look at file contents as **hexadecimal bytes** and **binary bits**;
- observe compile, link, invocation, and behavioral/test failures;
- repair one small intentional bug;
- rebuild and test from a clean state; and
- commit the intended source change with Git.

## Use the GitHub Codespace

The official R01 environment is the course-provided **GitHub Codespace** created from this repository.

A few things to keep in mind:

- Your own laptop may run Windows, macOS, or Linux. That is fine.
- The course commands run inside the Linux development container defined by `.devcontainer/`.
- You can connect using either:
  - the VS Code web client in your browser; or
  - VS Code desktop with the GitHub Codespaces extension.
- Even if the VS Code interface is running on your laptop, **GCC, Make, Git, the shell, the tests, and your C programs run inside the Codespace**.

## Use this as a Git repository

For the normal course workflow, work from a writable GitHub repository created from the course starter/template.

- **Do not use an extracted ZIP as your normal working copy.**
- Make your changes in the repository opened in Codespaces.
- Commit and push work that you want to keep.

## What's in the repository?

- `.devcontainer/`
  - Defines the supported Ubuntu 24.04 Codespaces environment.

- `main.c`, `ops.c`, `ops.h`
  - A tiny ISO C17 program used throughout the recitation.
  - The program contains **one intentional behavioral defect**. Do not fix it before the recitation asks you to.

- `Makefile`
  - Provides the supplied build, test, and clean commands.
  - You will inspect it in R01, but you do **not** need to edit it.

- `tests/test.sh`
  - Runs the deterministic behavioral check used in the recitation.

- `failures/compile_error.c`
  - A deliberately malformed C file used to observe a compile-time failure.

- `scripts/check_environment.sh`
  - Checks the Linux environment and verifies that the required R01 tools are available.

- `scripts/show_bytes.sh`
  - Displays file bytes in both hexadecimal and binary.
  - This is useful when you inspect object files and other build artifacts.

- `.gitignore`
  - Keeps generated build artifacts out of Git status and commits.

## Start here

Open the repository in its Codespace. From the repository root, run:

```sh
sh scripts/check_environment.sh
```

You should see checks for tools such as:

- GCC;
- GNU Make;
- Git;
- `file`;
- `readelf`;
- `objdump`;
- `objcopy`;
- `nm`; and
- `ldd`.

If the script reports a required tool as missing, stop and check that you are using the course Codespace.

## Check your repository baseline

Before changing anything, take a look at the repository state:

```sh
git status
git log -1 --oneline
git branch --show-current
git remote -v
```

You should start from a clean repository unless your instructor or TA has told you otherwise.

## A note about the intentional bug

The starter program is supposed to:

- build successfully;
- link successfully;
- run successfully; but
- **fail the supplied behavioral test** until you make the one-line repair during the recitation.

The correct program behavior is:

- stdout: `1` followed by a newline;
- process exit status: `0`.

So if the test fails before the repair, that is expected. **Do not treat that initial failure as a broken starter repository.**

## Compilation artifacts you will create

During R01, you will generate several files while following the GCC compilation pipeline:

- `main.i` — preprocessed C;
- `main.s` — assembly text;
- `main.o`, `ops.o` — relocatable object files;
- `program` — executable;
- `main.text.bin` — raw bytes extracted from the machine-code section for inspection.

These are generated artifacts, not authored source files. They are intentionally excluded from Git.

## Looking at bytes

The supplied helper can show the first few bytes of any readable file in both hex and binary:

```sh
sh scripts/show_bytes.sh main.o
```

You can also choose how many bytes to display:

```sh
sh scripts/show_bytes.sh main.o 16
```

The point is not to memorize binary. The goal is to see that the object file is ultimately stored as bytes, and that hexadecimal and binary are simply different ways of displaying those same byte values.

## Building with Make

Later in the recitation, you will use the supplied Makefile:

```sh
make
```

Run the test with:

```sh
make test
```

Remove generated build artifacts with:

```sh
make clean
```

After you repair the intentional defect, a clean reproduction should succeed:

```sh
make clean
make
make test
./program
```

## Before you finish

Before leaving the recitation:

- make sure `make test` passes after your repair;
- check `git status` so you know exactly what changed;
- commit only the intended source change; and
- push your commit to GitHub if the work needs to be retained.

Before deleting a Codespace, always make sure anything important has been **committed and pushed**. Deleting the Codespace can remove uncommitted work stored only inside that environment.
