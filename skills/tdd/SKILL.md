---
name: tdd
description: Test-first development in a red, green, refactor loop at agreed seams. Use for test-first work or when a ticket is being implemented.
---

# TDD

Work in vertical slices: one failing test, the least code that passes it, a tidy-up, repeat. Each test responds to what the last cycle taught you. Writing all the tests first and then all the code tests imagined behaviour, so do not.

## Seams

A seam is the public interface a test drives, where behaviour is observed without reaching inside. Test only at agreed seams, so effort goes to the paths that matter instead of every edge case.

A seam is agreed when the spec's testing section or the ticket names it, or the user confirmed it in this conversation. To test anywhere else, propose the seam with one line on what it catches and what it misses, and wait. A subagent cannot ask: it stops and reports `TICKET SCOPE CHANGE REQUIRED: new seam <name>`.

When the seam's shape is itself unclear (how deep the module is, what the interface exposes), consult the `codebase-design` skill for the vocabulary.

## The loop

1. Red: write one test at an agreed seam. Run it and see it fail for the expected reason.
2. Green: write only enough code to pass it. No speculative features.
3. Refactor: with the tests green, tidy the code this cycle wrote or touched (names, duplication, the shape the tests reveal). Run the tests after each change. Smells in code you did not touch belong to the review, not here.

Use GLOSSARY.md terms in test names, and respect the ADRs in the area you are touching.

## A good test

- Drives the public interface and checks what a caller can observe.
- Reads like a requirement: "user can check out with a valid cart".
- Survives a refactor that keeps behaviour the same.
- Gets its expected value from an independent source: a literal, a worked example, the spec. Recomputing it the way the code does proves nothing.
- Mocks only system boundaries: external APIs, time, randomness, sometimes the database or file system. Never your own modules.

If a test breaks when you refactor without changing behaviour, it is coupled to the implementation: it mocks internals, tests private functions, counts calls, or verifies through a side channel such as querying the database. Rewrite it against the interface.

Examples of each point are in [tests.md](tests.md).
