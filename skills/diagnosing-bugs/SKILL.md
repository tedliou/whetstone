---
name: diagnosing-bugs
description: Diagnoses hard bugs and performance regressions by building a red feedback loop first. Use when asked to debug, or something is broken or slow.
---

# Diagnosing bugs

A bug is found by a tight loop, not by reading code. A tight loop is one command that runs in seconds, gives the same verdict every run, and goes red on this exact bug. Build it before forming any theory. Work through the phases in order; skip one only when you can say why.

```
loop -> reproduce -> minimise -> hypothesise -> instrument -> fix -> clean up
 ^ no theory before this command exists
```

Read `GLOSSARY.md` and the ADRs in `docs/adr/` that touch the area, if they exist, so you name modules the way the project does.

## Redact

You will show commands, output, and captured data. Replace every secret with `<REDACTED>` before showing it. Pass credentials through environment variables so they stay out of the loop's source. From captured requests, quote only the lines that carry the signal. If redacted output is not enough to diagnose, say so and ask the user.

## 1. Build a feedback loop

This phase is most of the work. Try several kinds of loop before concluding none can be built. Roughly in this order:

1. A failing test at whatever seam reaches the bug (unit, integration, e2e).
2. A curl or HTTP script against a running dev server.
3. A CLI call with a fixture input, diffing output against a known-good snapshot.
4. A headless browser script (Playwright, Puppeteer) asserting on DOM, console, or network.
5. A replay of a captured request, payload, or event log through the code path in isolation.
6. A throwaway harness: the smallest subset of the system that reaches the bug in one call.
7. A property or fuzz loop: many random inputs, looking for the failure.
8. A bisection harness for "it worked at state X": script the check and run `git bisect run`.
9. A differential loop: same input through the old and new version (or two configs), diff the output.
10. A human-in-the-loop script, as a last resort. See [Human in the loop](#human-in-the-loop).

Then tighten it: make it faster (cache setup, narrow scope), sharper (assert the exact symptom, not "did not crash"), and deterministic (pin time, seed randomness, isolate the filesystem and network).

For an intermittent bug, aim for a higher reproduction rate, not a clean repro: loop the trigger many times, run in parallel, add load, inject sleeps. Keep raising the rate until it fails often enough to debug.

If no loop can be built, stop. List what you tried and ask the user for one of: access to an environment that reproduces it, a redacted capture (HAR, log dump, core dump, timestamped recording), or permission to add temporary production logging.

Done when you can name one command, have run it at least once (show the call and redacted output), and it is:

- red-capable: it drives the real code path and asserts the user's exact symptom, so it goes green only when this bug is fixed;
- deterministic: same verdict every run, or a pinned high failure rate for intermittent bugs;
- fast: seconds, not minutes;
- runnable by you without help, except through the human-in-the-loop script.

## 2. Reproduce and minimise

Run the loop and watch it go red. Check that:

- the failure is the one the user described, not a nearby one;
- it fails on repeated runs (or at a high enough rate);
- you have recorded the exact symptom (message, wrong value, timing) to verify the fix against.

Then shrink the scenario. Remove one input, caller, config value, or step at a time and rerun. Keep only what keeps it red. A smaller repro leaves fewer suspects and becomes the regression test. Done when removing any remaining element turns the loop green.

## 3. Hypothesise

Write 3 to 5 ranked hypotheses before testing any. One hypothesis anchors you on the first plausible idea. Each states a prediction:

```
If <X> is the cause, then changing <Y> makes the bug disappear (or changing <Z> makes it worse).
```

A hypothesis with no prediction gets sharpened or dropped. Show the ranked list to the user; they often know what changed recently or what is already ruled out. Do not wait for an answer if they are away.

## 4. Instrument

Each probe tests one prediction. Change one variable at a time.

- Prefer a debugger or REPL; one breakpoint beats ten log lines.
- Otherwise log at the boundaries that tell the hypotheses apart. Never log everything and grep.
- Tag every debug line with one unique prefix such as `[DEBUG-a4f2]`, so cleanup is one search.

For performance regressions, measure instead of logging: take a baseline with a timer, profiler, or query plan, then bisect.

## 5. Fix with a regression test

If the fix is more than a few lines, or touches behaviour other code depends on, offer to open a GitHub issue first (`gh issue create`, see [github.md](../_shared/github.md)) with the symptom, the loop command, and the confirmed hypothesis. Then branch and commit as in [workflow.md](../_shared/workflow.md).

Write the regression test before the fix, at a seam that reproduces the real bug pattern. A seam that is too shallow (one caller when the bug needs two, a unit test that skips the chain that triggers it) gives false confidence. If no such seam exists, report that as a finding: the design is stopping the bug from being locked down, and `improve-codebase-architecture` is the place to address it.

With a good seam:

1. Turn the minimised repro into a failing test there.
2. Watch it fail. If you forced the failure by editing code or a fixture, diff against a clean copy to prove the edit took effect.
3. Apply the fix and watch the test pass.
4. Rerun the phase 1 loop on the original, unminimised scenario.

## 6. Clean up

Done when all hold:

- the phase 1 loop no longer reproduces the bug;
- the regression test passes, or the missing seam is reported;
- a search for the debug prefix finds nothing;
- throwaway harnesses are deleted;
- the commit or PR message states which hypothesis was correct.

## Human in the loop

When only a person can trigger the bug (clicking through a UI, a device), script their steps so the loop stays structured. Copy the template that matches the user's shell to a temp directory, outside the repo:

- bash: `${CLAUDE_SKILL_DIR}/scripts/hitl-loop.template.sh`
- PowerShell: `${CLAUDE_SKILL_DIR}/scripts/hitl-loop.template.ps1`

Edit the steps between the markers. `step` shows an instruction and waits for Enter; `capture` asks a question and records the answer. The script is interactive, so ask the user to run it in their own terminal and paste back the `Captured` block it prints. Use `step` for anything involving sign-in, so no credential is ever captured.
