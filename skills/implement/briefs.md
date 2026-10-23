# Implementer brief

Fill every `<...>` and send it as the subagent prompt with `model: "sonnet"`. The subagent sees nothing else, so paste the ticket text in full.

```
Implement GitHub ticket #<n> in <working directory>.

Ticket:
<full ticket body>

Spec context you need: <the spec stories and decisions this ticket points at, quoted>
Agreed test seams: <seams from the spec's testing section>
Terms: read GLOSSARY.md and the ADRs under docs/adr/ that touch <areas>.

Rules:
- Work test-first: one failing test at an agreed seam, the least code to pass, tidy what you wrote, repeat.
- Change only files under: <expected areas>. Other tickets are being worked in parallel elsewhere in this tree.
- Run only this ticket's tests: <focused test command>. Do not run the full suite.
- <"Do not commit. Leave your changes in the working tree." | "Commit on branch <branch> with message type(scope): summary and trailer Refs #<n>.">
- If the work needs anything outside Scope, a new test seam, or files outside your areas, stop and report the scope change. Do not work around it.
- Never edit GitHub issues.

Reply with exactly one of these, then the list of files you changed, then nothing else:
DONE: <one line on what now works> | tests: <command and result>
TICKET SCOPE CHANGE REQUIRED: <what is needed and why>
BLOCKED: <what stopped you>
```
