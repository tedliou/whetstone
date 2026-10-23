---
name: domain-modeling
description: Writes GLOSSARY.md terms and ADRs in docs/adr/ as domain language settles. Use when terms are disputed or a decision needs recording.
---

# Domain modeling

Sharpen the project's domain language while designing, and write each settled term or decision down the moment it settles. Reading `GLOSSARY.md` for vocabulary does not need this skill; changing it does.

Two files, at fixed paths. Create each only when there is something to write.

| File | Holds |
|---|---|
| `GLOSSARY.md` at the repo root | Domain terms: what each one is, and the words to avoid |
| `docs/adr/NNNN-slug.md` | One hard-to-reverse decision and why |

Edits made while grilling stay uncommitted; [workflow.md](../_shared/workflow.md#commits) says when and how they get committed.

## During the conversation

- Challenge against the glossary. When the user uses a term differently from `GLOSSARY.md`, say so at once: "The glossary defines cancellation as X, but you seem to mean Y. Which is it?"
- Sharpen fuzzy words. When a word is vague or overloaded, propose one precise term: "By account, do you mean the Customer or the User?"
- Test with concrete scenarios. Invent edge cases that force a clear line between two concepts.
- Check the code. When the user says how something works, look. Raise any contradiction: "The code cancels whole Orders, but you said partial cancellation is possible. Which is right?"
- Write as you go. Update `GLOSSARY.md` as soon as a term is settled, not in a batch at the end.

## GLOSSARY.md

```md
# {Project or context name}

{One or two sentences: what this domain is and why it exists.}

## Language

**Order**:
A customer's request to buy one or more products.
_Avoid_: purchase, transaction

**Invoice**:
A request for payment sent to a customer after delivery.
_Avoid_: bill, payment request
```

- Pick one word per concept and list the others under `_Avoid_`.
- One or two sentences per term. Say what it is, not what it does.
- Only terms specific to this domain. General programming ideas (timeout, retry, error type) stay out even if the code uses them a lot.
- Group terms under subheadings when clusters appear; a flat list is fine otherwise.
- No implementation details. The glossary is not a spec or a notes file.

## ADRs

Offer an ADR only when all three hold:

1. Hard to reverse: changing your mind later costs real effort.
2. Surprising without context: a future reader would ask why it was done this way.
3. A real trade-off: there were genuine alternatives and one was picked for a reason.

Typical cases: architectural shape, how two parts of the system talk to each other, technology with lock-in, who owns which data, a deliberate departure from the obvious approach, a constraint the code does not show (compliance, a partner's latency contract), and a rejected alternative someone is likely to propose again.

Number it one above the highest file in `docs/adr/`, starting at `0001`. Usually one paragraph is enough:

```md
# {Short title of the decision}

{1 to 3 sentences: the context, what was decided, and why.}
```

Add these only when they carry real information:

- `Status` frontmatter: `proposed`, `accepted`, `deprecated`, or `superseded by ADR-NNNN`.
- Considered options: when the rejected alternatives are worth remembering.
- Consequences: when the downstream effects are not obvious.
