# rbc readiness repository

This repository is the starter project for the readiness recitation. It contains a small C17 command program and uses the course build and test layout.

During the recitation, inspect the project but do not modify source or tests unless your instructor or TA asks you to do so.

## Environment check

From the repository root:

```sh
./scripts/setup_environment.sh --check
```

Linux/GitHub Codespaces is the course reference environment. Supported local macOS tooling is also recognized where practical.

## Build and run

```sh
make
printf 'add 2 3\nsub 9 4\n' | build/normal/bin/rbc
```

Expected output:

```text
5
5
```

The program accepts `add` and `sub`, each followed by two small integer operands.

## Tests

```sh
make test
```

Criterion tests are under `tests/unit/`; process tests are under `tests/cli/`; fixtures are under `tests/fixtures/`.

Generated objects, dependency files, test binaries, and the executable are written under `build/`. Remove them with:

```sh
make clean
```
