---
name: chez-readme
description: >
  Protect the chez-ccamel README during repository work. Use for any change to
  this repository, including tools, Nix configuration, resources, code, and
  documentation, and before any command that might regenerate the README.
---

# Protect the README

- Do not manually edit `README.md` unless the user explicitly requests it. A request to change code, tools, configuration, or documentation in general is not permission to hand-edit the README.
- README tool tables are generated from repository metadata. Update the relevant metadata when the requested tool change requires it, then regenerate using `just generate-readme` or a `just` recipe that invokes it. No explicit README request is required for regeneration.
- Prefer changing metadata and regenerating over hand-editing generated rows, which would be overwritten by the next regeneration.
