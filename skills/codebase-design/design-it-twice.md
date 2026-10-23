# Design it twice

The first interface you think of is rarely the best. Generate several very different ones in parallel, then compare.

## 1. Frame the problem

Write a short explanation for the user: the constraints any interface must meet, the dependencies and their category (see the table in [SKILL.md](SKILL.md#dependencies-decide-how-to-deepen)), and a rough code sketch that makes the constraints concrete. The sketch is not a proposal. Show it, then start step 2 right away so the user reads while the subagents work.

## 2. Spawn subagents

Start three or four subagents in one message. Each gets the brief below with a different constraint:

| Agent | Constraint |
|---|---|
| 1 | Smallest interface: one to three entry points, maximum leverage each. |
| 2 | Most flexible: support many use cases and extension. |
| 3 | Best for the most common caller: make the default case trivial. |
| 4 (if a dependency is remote or external) | Built around ports and adapters at each seam. |

```
Design an interface for one deep module in this repo. Do not edit any file.

Goal: {what the module does, one or two sentences}
Files involved: {paths}
Current coupling: {who calls what, where logic leaks}
Dependencies: {each one and its category: in-process, local stand-in, remote owned, external}
What should sit behind the seam: {logic the callers should stop knowing about}
Your constraint: {one row from the table}

Vocabulary: module, interface, implementation, depth, seam, adapter, leverage, locality.
{paste the Terms table from codebase-design SKILL.md}
Domain terms: {relevant entries from GLOSSARY.md, or "none"}

Return, in this order:
1. Interface: types and methods, plus invariants, call order, and error modes.
2. A usage example from a caller's side.
3. What the implementation hides.
4. Dependency strategy and adapters.
5. Trade-offs: where leverage is high and where it is thin.
```

## 3. Compare and recommend

Present the designs one at a time, then compare them on depth, locality, and seam placement. End with your pick and why. If parts of two designs combine well, propose the hybrid. Give a clear opinion, not a menu.
