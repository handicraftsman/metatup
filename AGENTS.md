# AGENTS.md

## Purpose

This repository is the Tup build system itself. Treat Tupfiles and supporting `.tup` files as first-class source code: changes to build rules can affect parser behavior, dependency tracking, variants, generated outputs, and tests.

## Repository layout

- `Tupfile` is the top-level build graph entry.
- `Tuprules.tup` defines shared compiler/linker flags and common Tup macros such as `!cc`, `!ld`, `!ar`, `!dot`, and `!cp`.
- `*.tup` files in the repository root select platform-specific settings included by `Tuprules.tup`.
- `src/**/Tupfile` files are mostly thin leaf rules that rely on `include_rules`.
- `test/` contains the shell-based regression suite. `test/tup.sh` provides the shared test harness.
- `Tupfile.ini` is intentionally present so `tup` can auto-initialize `.tup` at the repo root.

## Preferred workflow

### Initial bootstrap

Use `./bootstrap.sh` for a clean local bring-up. It bootstraps a temporary `build/` toolchain build, initializes `.tup` if needed, and then runs Tup to produce the real binary.

If you need only the bootstrap-stage binary, `./build.sh` builds into `build/` without initializing or updating the tree.

### Incremental development

Use `tup` or `./tup` for normal updates after the initial bootstrap. The manual states that plain `tup` is the primary command and may be run from anywhere inside the Tup hierarchy.

Useful commands:

- `tup`
- `tup <target>`
- `tup -jN`
- `tup todo`
- `tup graph <target>`

### Tests

Run tests from `test/`:

- `cd test && ./test.sh` for the full suite
- `cd test && ./test.sh t0000-init.sh` for a single test
- `cd test && ./test.sh --keep-going` to continue after failures

The tests expect the local Tup binary to be found first in `PATH`; `test/tup.sh` handles that.

## Tup-specific rules for agents

### When editing Tupfiles

- Preserve the current DAG unless the task explicitly requires a build graph change.
- If the task is a refactor of Tup syntax, variables, macros, or rule formatting without intended DAG changes, run `tup refactor` before treating the edit as complete. Per the manual, `tup refactor` should succeed only when the parsed rule set is semantically unchanged.
- Be careful with changes that add or remove commands, generated inputs, outputs, groups, `.gitignore` directives, or directory-level dependencies; those are not refactor-safe changes.
- Most compile and link behavior is centralized in `Tuprules.tup`; prefer changing shared macros there instead of duplicating command fragments in leaf Tupfiles.
- Keep `include_rules` usage consistent in subdirectory Tupfiles.

### `tup.config` and `@` variables

- Tup configuration variables come from `tup.config` and are consumed as `@(NAME)` in Tupfiles.
- Keep `tup.config` formatting exact: `CONFIG_FOO=y` is valid, while `CONFIG_FOO = y` changes the parsed variable name and value.
- `# CONFIG_FOO is not set` explicitly maps `FOO` to `n`.
- `@(TUP_PLATFORM)` and `@(TUP_ARCH)` are special built-ins used by this repository’s platform selection logic.

### Variants

- Tup variants are build directories that contain their own `tup.config`.
- When working with variant builds, keep artifacts inside the variant directory and do not mix assumptions from in-tree builds with variant builds.
- If you add or modify variant-sensitive logic, verify both the default configuration and at least one non-default variant when practical.

### Generated artifacts

- Do not manually edit files produced by Tup or the bootstrap process.
- Avoid committing `.tup/`, `build/`, variant output directories, or other generated artifacts unless the task explicitly requires generated output updates.

## Validation expectations

For build-logic changes, prefer the smallest validation that proves the change:

- `tup refactor` for Tupfile-only refactors
- `tup <target>` or `tup` for real graph changes
- targeted regression tests in `test/`
- `cd test && ./test.sh` when the change is broad or risky

If compiler command generation changes and external tooling needs an updated compilation database, run `tup compiledb` manually. The manual notes that `compile_commands.json` is not refreshed automatically when Tupfiles change.

## Agent guidance

- Read the relevant `Tupfile`, `Tuprules.tup`, and platform `.tup` files before changing build behavior.
- Prefer targeted test coverage over blind full-suite runs, but escalate to the full suite for parser, updater, monitor, variant, or dependency-graph changes.
- Do not replace Tup-driven workflows with ad hoc scripts or alternate build systems unless the task explicitly asks for that.
- If a CI-like environment cannot run Tup directly, note that the manual documents `tup generate`, but do not introduce generated shell scripts into the repository unless requested.
