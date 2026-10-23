---
name: grill
description: Interviews the user in rounds of numbered questions with recommended answers until a plan is clear. Use when asked to grill or stress-test a plan.
argument-hint: "[topic or #issue]"
---

# Grill

Interview the user until you both understand the plan the same way. Nothing is built during a grill.

## How a round works

Treat the plan as a tree of decisions: each decision opens the ones that depend on it. Each round, ask every question whose prerequisites are already settled, and only those. A question that depends on another question in the same round waits for a later round.

Format a round as plain text, no emoji or bold:

```
Q1. <short title>
<the question, with options when there are several>
Recommended: <your answer>

Q2. ...
```

Word each question so "yes" accepts your recommendation. Wait for the answers, then recompute which questions are now askable and run the next round.

Facts are your job; decisions are the user's. If a question needs a fact from the code, docs, or tools, look it up yourself or send a subagent, and meanwhile ask the questions that do not depend on it. Never ask the user something you could find out.

The grill is done when no open question is left and nothing is silently assumed. Confirm that with the user before moving on.

## Inside a repo

Use the `domain-modeling` skill alongside: challenge vague or overloaded terms as they come up, and record settled terms in GLOSSARY.md and hard-to-reverse decisions in docs/adr/. Leave these edits uncommitted; implement commits them on the spec branch ([workflow.md](../_shared/workflow.md#commits)).

If the argument is an issue number, read it first (`gh issue view <n> --json title,body,comments`) and grill from there.

## Ending

Summarise the decisions in a short list. If GLOSSARY.md or ADRs changed, list those files and note that they are not committed yet. Then ask whether to continue with `to-spec`. On yes, invoke it.
