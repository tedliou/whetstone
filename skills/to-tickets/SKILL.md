---
name: to-tickets
description: Splits a GitHub spec issue into ticket sub-issues with blockers and checkpoints. Use when asked to break a spec down, or after to-spec.
argument-hint: "#spec"
---

# To tickets

Split one spec into tickets: GitHub sub-issues of the spec, each a thin slice that can be finished and verified on its own, linked with native blocked-by relationships. Words and rules: [workflow.md](../_shared/workflow.md).

Shared scripts: `${CLAUDE_SKILL_DIR}/../_shared/scripts/` (how to run them: [workflow.md](../_shared/workflow.md#scripts)).

## Steps

1. Run `context`; stop if `gh` is not `ok`. Read the spec: `gh issue view <spec> --json title,body,comments`. Run `tickets <spec>`: if its first line carries the spec number, sub-issues already exist, so show them and ask before adding more (`spec - - -` means none yet).
2. Explore the code the spec touches. Look for prefactoring that makes the rest easier; it becomes the first ticket.
3. Draft the split (rules below) and show it as a numbered list: title, blocked by, what it delivers, expected areas, checkpoint or not. Check that every case in the spec's Testing section belongs to exactly one ticket's Scope.
4. Ask once, with your recommendation for each: is the size right, are the blockers real, which tickets are checkpoints. Iterate until approved.
5. Create tickets in dependency order, blockers first, so blockers have real numbers: `gh issue create --title <t> --body-file - --parent <spec> [--blocked-by <a>,<b>]` with the body on stdin. Write sibling links in Non-goals as `#?<title>` placeholders for tickets not created yet.
6. Replace the placeholders with real numbers: `gh issue edit <n> --body-file -`.
7. Run `tickets <spec>` and show its output as the result. Then ask whether to continue with `implement #<spec>`. On yes, invoke it.

Do not edit or close the spec.

## Splitting rules

- Vertical slices: each ticket cuts through every layer it needs (data, logic, interface, tests) and is demoable or verifiable alone. Never one ticket per layer.
- Each ticket fits in one fresh context window.
- Blocked-by only when a ticket truly cannot start before another finishes.
- Tickets that would edit the same files should block one another, or be merged, so they never run in parallel. Tickets with no blocker between them must list disjoint files in Expected areas; implement relies on that to run them in parallel.
- Wide mechanical refactors (a rename across the codebase) go expand, migrate, contract: add the new form beside the old, migrate callers in batches that each stay green, then delete the old form in a ticket blocked by every batch.
- Checkpoint: a ticket whose mistakes would spread into later tickets (a shared interface, a schema, a risky core change). Few tickets need it; everything else is reviewed once at PR time.

## Ticket body

Translate headings to the output language. The spec's content applies to every ticket, so point at it instead of repeating it.

```markdown
## Context
Spec stories this ticket delivers (by number), and what the spec does not say: current state found while splitting, spec decisions this ticket changes.

## Scope
- [ ] <situation> -> <observable result>
- [ ] Spec decision "<name>" holds for the part this ticket owns
- Stop if <ticket-specific stop condition>

## Non-goals
- <tempting overreach> -> #<sibling ticket>

## Expected areas
- <directory>: <main files expected to change>

## Verification
<a command that runs only this ticket's tests, when one exists>
```

- Scope items are checkable from the diff or by running something. Do not list things the project's normal test run already covers.
- Leave out Non-goals and Verification when empty.
- For a checkpoint ticket, add a last line containing exactly `<!-- whetstone:checkpoint -->`.
- No code. File paths belong only in Expected areas.
