---
name: writing-for-agents
description: Rules for writing skills, CLAUDE.md, and other files agents read. Use when creating or editing a skill, CLAUDE.md, or a subagent brief.
---

# Writing for agents

Token cost and model confusion are the two enemies. Every rule here cuts one or the other. They apply to skills, CLAUDE.md and AGENTS.md files, reference files, and subagent briefs.

## Rules that always hold

- Put the rules that must hold first and examples last. After compaction only the first 5,000 tokens of a skill survive, so keep a `SKILL.md` body well under that.
- One fact lives in one place. When several skills share a rule, put it in one shared file and link to it. Repeating a rule costs tokens on every load and makes it look more important than it is.
- Say what to do and why. A reason lets the model handle cases the rule did not foresee.
- State the behaviour you want, not the one you forbid. "Write one-line comments" works better than "do not write long comments", because naming a behaviour makes it more likely. Keep a prohibition only as a hard guardrail, and pair it with the positive target.
- No MUST, CRITICAL, capitals, bold, or italic for emphasis. They raise the volume of one line and lower everything else.
- Write in English. Never tell the model which language to reply in; that comes from the user's CLAUDE.md, else the language of their message. Templates say "translate headings to the output language".
- Plain words and short complete sentences. Cut repetition and filler; do not compress into jargon or abbreviations. Explain a term in one sentence the first time it appears.
- Use a list for parallel items, a table when items have two or more attributes, and a plain-text diagram instead of a long paragraph. No emoji. No em-dashes.

## Cut what does not change behaviour

Read every sentence and ask: would the model act differently without it? If not, delete the whole sentence.

- No-ops: instructions the model already follows by default ("be careful", "write clean code"). If the default really is too weak, use a stronger, more specific word instead of more words.
- Copies of the environment: facts the model can get with one command or one file read (scripts in `package.json`, directory layout, `--help` output). They go stale. Record only what looking cannot reveal: unwritten conventions, the reason behind a choice, known traps.
- Motivation, history, and examples that teach nothing new. Keep an example only when it fixes a format or settles an ambiguity.
- Stale lines. When behaviour changes, remove the old text in the same edit; otherwise layers of outdated rules pile up.

## Structure

Each piece of content sits at one of three levels:

| Level | What goes there |
|---|---|
| Steps in the main file | What the agent does, in order |
| Reference in the main file | Rules and facts every run needs |
| A linked reference file | Material only some runs need: long formats, rarely used branches, subagent briefs |

Inline what every path through the document needs; move behind a link what only some paths reach. Link one level deep, from the main file, and say in the link when to read it. Keep a concept's definition, rules, and caveats under one heading, not scattered.

Use one compact word for a recurring idea instead of a repeated phrase: "a tight loop" instead of "fast, deterministic, low-overhead", "goes red" instead of "a test you trust". Prefer words the model already knows; a coined word needs a definition.

## Steps end on a check

Every step ends with a completion check: a condition the agent can verify. "Understanding reached" invites stopping early; "every caller of `parse` listed with its file" does not. The stronger the check, the more digging the agent does. If a step keeps being rushed because later steps are visible, split the later steps into a separate skill or subagent; hiding them only works across a real context boundary.

## Descriptions and pointers

A skill's `description` and every line in CLAUDE.md that points to another file are always loaded, so each word costs on every turn. The wording, not the target, decides whether the agent reaches the material.

- Third person. Say what it does, then when to use it. Key words first.
- One trigger per distinct case. Synonyms for the same case are waste.
- Leave out what the body already says.
- If a needed file is not being reached, sharpen the pointer before inlining the file.

## Skills

Frontmatter:

```yaml
---
name: folder-name
description: Does X for Y. Use when Z.
---
```

Choose who can invoke it:

| Kind | Frontmatter | Cost and reach |
|---|---|---|
| Model-invocable | `description` with triggers | Description always in context; the model and other skills can call it, and the user can still type it. |
| User-only | `disable-model-invocation: true`, an `argument-hint`, a one-line description | No context cost; only the user can start it, so the user must remember it exists. |

Make a skill model-invocable only when the model or another skill needs to reach it. Shared reference that two user-only skills need goes in a plain file both link to, since neither can call the other.

Split a skill in two only when the split pays: a separate trigger word the user actually types, another skill needs to reach part of it, or a long run of steps tempts the agent to rush.

Mechanics that keep skills reliable:

- Deterministic git or API operations go in a script the skill calls, not in prose the model turns into commands. Scripts print plain text, one record per line, with errors that say how to fix them. Keep scripts ASCII only.
- When users run different shells, ship a bash and a PowerShell version with the same arguments and output, and tell the model to use whichever shell tool it has.
- Avoid `!` command injection: it runs in one fixed shell, and a failure stops the skill from loading.
- Skills do not write config files into the projects they run in. Read facts from the project's CLAUDE.md, ask once if missing, and keep the answer in auto memory.
- A subagent sees only its brief. Write briefs as fill-in templates in a reference file, listing every input and the exact output shape.

## CLAUDE.md and AGENTS.md

These load into every session in their scope, so they cost the most per word.

- Keep them to what the agent cannot find by looking: commands that are not obvious, conventions, fixed vocabulary, where things live, and pointers to longer docs.
- Move rules that only a reviewer needs into the review standards file, and rules a tool can check into a linter, hook, or CI job.
