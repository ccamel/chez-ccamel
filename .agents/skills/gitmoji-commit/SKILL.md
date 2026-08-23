---
name: gitmoji-commit
description: Draft and verify gitmoji-style commit messages that match chez-ccamel's commitlint policy. Use when creating, revising, checking, or explaining a commit message for this repository.
---

# Write a gitmoji commit message

## Inputs

Inspect the staged or explicitly targeted change, recent repository commit subjects for tone, and the current `type-enum` in `commitlint.config.mjs`.

When asked only for wording, return wording without staging or committing. When asked to commit, base the message on staged changes and preserve unrelated work.

## Workflow

1. Give each commit one cohesive primary intent. Split independently useful concerns only when the user requested commit creation and the staged change is genuinely separable.
2. Choose exactly one allowlisted named alias, then emit `<alias> <subject>` with exactly one space.
3. Write a concise imperative subject in sentence case, with no trailing period. Keep the complete header at most 75 characters.
4. Do not emit raw Unicode emoji, Conventional Commit `feat:` or `fix:` types, scopes, or `!` syntax. This parser captures only `type` and `subject`.
5. Add an optional explanatory body or footer only after a blank line. Keep every body and footer line at most 100 characters, matching the inherited conventional rules.

## Type selection

Treat `commitlint.config.mjs` as the allowlist source of truth. Select by the change's primary outcome rather than the files touched:

- `:robot:` — agent skills or automation behavior.
- `:sparkles:` — new capability or newly installed tool.
- `:bug:` / `:ambulance:` — ordinary fix / critical hotfix.
- `:zap:` / `:recycle:` / `:art:` — performance / behavior-preserving refactor / structure or formatting.
- `:fire:` / `:truck:` / `:rewind:` — removal / move or rename / revert.
- `:memo:` / `:white_check_mark:` — documentation / tests.
- `:construction_worker:` / `:green_heart:` — CI or build-system definition / repair of failing CI.
- `:wrench:` — configuration whose primary outcome is not covered by a more specific alias.
- `:arrow_up:` / `:arrow_down:` / `:pushpin:` — upgrade / downgrade / pin a dependency or managed resource.
- `:heavy_plus_sign:` / `:heavy_minus_sign:` — add / remove a dependency.
- `:lock:` / `:boom:` — security or privacy fix / breaking change.

For an allowlisted alias outside this table, use established repository history or gitmoji.dev semantics. Never invent an alias or expand the enum while drafting a message.

## Verification

Check the final first line against the current parser, enum, sentence-case and no-period rules, and the 75-character limit. If a commit was requested and created, inspect its recorded subject. Once pushed, `.github/workflows/lint-commits.yml` is the authoritative full commitlint run.

## Guardrails

Do not amend, rebase, stage unrelated files, or change commit policy unless the user explicitly requests that operation. Default-ignored commit patterns are not a way to bypass the authored-message policy. This skill remains checkout-only.
