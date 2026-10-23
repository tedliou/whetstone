---
name: improve-codebase-architecture
description: Finds deepening opportunities in a codebase, shows them as an HTML report, then grills the one you pick.
argument-hint: "[area, module, or pain point]"
disable-model-invocation: true
---

# Improve codebase architecture

Find places where shallow modules should become deep ones, so the code is easier to test and to navigate. Call the Skill tool with "codebase-design" first and use its terms exactly (module, interface, depth, seam, adapter, leverage, locality). Name domain concepts as `GLOSSARY.md` does. Treat ADRs in `docs/adr/` as settled unless the friction is strong enough to reopen one.

```
choose scope -> explore -> HTML report -> user picks -> grill -> spec (optional)
```

## 1. Choose the scope

Deepening pays off where code keeps changing, so decide where to look before looking.

- If the user named an area, module, or pain point, use it.
- Otherwise read a long stretch of `git log --oneline --name-only` and find the files and directories that change most. Start there. If changes are spread evenly, widen the search.

## 2. Explore

Read `GLOSSARY.md` and the ADRs for the area. Then send a subagent through the code with this brief, filled in:

```
Explore {scope} in this repo and report architectural friction. Do not edit any file.
Use these terms: {paste the Terms table from codebase-design}.
Look for:
- concepts that need jumping between many small modules to understand;
- shallow modules, whose interface is nearly as complex as the implementation;
- logic split into pure functions for testing while the bugs live in how they are called;
- coupled modules that leak across their seams;
- code that is untested or hard to test through its current interface.
Apply the deletion test to each suspect: if deleting it would make its complexity vanish, it is a pass-through worth merging.
Return one entry per candidate: files, problem, proposed deepening, dependency category, evidence.
```

## 3. Report

Write one self-contained HTML file to the OS temp directory (`$TMPDIR`, else `/tmp`; `%TEMP%` on Windows) as `architecture-review-<timestamp>.html`, so nothing lands in the repo. Open it (`start`, `open`, or `xdg-open`) and give the user the absolute path. Build it as described in [html-format.md](html-format.md).

Each candidate gets: files, problem, solution, benefits in terms of locality and leverage (including how tests improve), a before and after diagram, and a strength badge (`Strong`, `Worth exploring`, `Speculative`). If a candidate contradicts an ADR, include it only when the friction justifies reopening the ADR, and mark the conflict on the card. End with the one candidate you would do first and why.

Do not propose interfaces yet. Ask which candidate the user wants to explore.

## 4. Grill the chosen candidate

Call the Skill tool with "grill" for the chosen candidate: constraints, dependencies, the shape of the deep module, what sits behind the seam, which tests survive. Keep the domain model current through "domain-modeling" as decisions settle:

- A deep module named after a concept missing from `GLOSSARY.md`: add the term.
- The user rejects the candidate for a lasting reason: offer an ADR so later reviews do not suggest it again. Skip reasons that are temporary ("not now") or obvious.
- The user wants alternative interfaces: use the design-it-twice process from "codebase-design".

When the design is settled, ask whether to continue with to-spec.
