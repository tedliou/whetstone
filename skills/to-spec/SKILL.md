---
name: to-spec
description: Writes the current discussion up as a GitHub spec issue. Use when asked for a spec, or when continuing from grill.
argument-hint: "[#issue to build on]"
---

# To spec

Turn what is already known (this conversation, the code, an issue passed as argument) into one spec issue. Do not interview again. The only question is the seam check in step 3.

## Steps

1. Run `context` ([workflow.md](../_shared/workflow.md#scripts)). Stop if `gh` is not `ok`.
2. Explore the code you have not seen yet. Use GLOSSARY.md terms and respect the ADRs in the area.
3. Seams: choose where the feature will be tested. Prefer existing seams and the highest one possible; fewer is better, one is ideal. If the seams were already settled while grilling, state them and move on; otherwise propose them and wait for the user.
4. Write the body from the template below into a temp file and create the issue: `gh issue create --title <title> --body-file <file>`. Do not create a branch; implement does that.
5. Report the issue URL, then ask whether to continue with `to-tickets`. On yes, invoke it with the spec number.

## Writing rules

- Say each fact once, in the section it belongs to, with its reason next to it.
- One user story per user goal. Edge and failure cases go in the matching decision and in testing, not as extra stories.
- No file paths or code; they go stale. A short type shape or state machine is fine when prose would be less exact.
- Mention a rejected alternative only inside the reason of the decision that beat it.
- Do not restate rules the project's CLAUDE.md already sets.

## Template

Translate headings to the output language.

```markdown
## Problem
The problem from the user's point of view.

## Solution
The direction from the user's point of view: what changes, in what form, the key trade-offs.

## User stories
1. As a <actor>, I want <capability>, so that <benefit>.

## Decisions
- <decision>: <reason, and its cost if any>
  Covers modules and their interfaces, schema and API contracts, and existing behaviour that must stay.

## Testing
- Seam <name> (stories 1, 3): <what it checks>; edge and failure cases: <list>; fixtures or test doubles: <list>
- Not tested: <what, and why>

## Out of scope
- <thing not done, when no decision above already says so>

## Domain changes
- GLOSSARY.md: <terms added or changed>
- docs/adr/<file>: <decision>
(Not committed yet; implement commits them on the spec branch. Omit this section when nothing changed.)
```
