# HTML page format

One static HTML file. Tailwind and Mermaid load from CDNs; there is no other script. Diagrams carry the content; prose is sparse and uses the codebase-design terms.

## Scaffold

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>Architecture review: {repo}</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <script type="module">
    import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";
    mermaid.initialize({ startOnLoad: true, theme: "neutral" });
  </script>
  <style>
    .seam { stroke-dasharray: 4 4; }
    .leak { stroke: #dc2626; }
  </style>
</head>
<body class="bg-stone-50 text-slate-900">
  <main class="max-w-5xl mx-auto px-6 py-12 space-y-12">
    <header><!-- repo, date, legend --></header>
    <section id="candidates" class="space-y-10"><!-- one article per candidate --></section>
    <section id="top"><!-- top recommendation --></section>
  </main>
</body>
</html>
```

## Header

Repo name, date, and a legend: solid box is a module, dashed line is a seam, red arrow is leakage, thick dark box is a deep module. No introduction.

## Candidate card

One `<article>` per candidate:

| Part | Content |
|---|---|
| Title | Names the deepening, for example "Collapse the Order intake pipeline" |
| Badges | Strength (`Strong` emerald, `Worth exploring` amber, `Speculative` slate) and dependency category |
| Files | `font-mono text-sm` list |
| Before / after | Two diagrams side by side, about 320px tall |
| Problem | One sentence |
| Solution | One sentence |
| Wins | Bullets of six words or fewer, in glossary terms: "locality: bugs sit in one module", "leverage: one interface, N callers" |
| ADR conflict | One line in an amber box, only when present |

If a diagram needs a paragraph to be understood, redraw it.

## Diagram patterns

Vary them across candidates.

| Pattern | Use for | How |
|---|---|---|
| Mermaid flowchart or sequence | Call flow, dependencies, round trips | `<pre class="mermaid">` in a white bordered card; `classDef` colours leaking edges red |
| Boxes and arrows | An "after" showing one thick deep module with faded internals | Bordered `<div>`s, inline SVG arrows over a relative container |
| Cross-section | Calls passing through many thin layers | Stacked bands; after: one thick band |
| Mass diagram | Interface as wide as the implementation | Two rectangles per module, interface height against implementation height |
| Call-graph collapse | Many small functions becoming one module | Nested boxes; after: one box with the calls faded inside |

## Style

- Plenty of whitespace; one accent colour, plus red for leakage and amber for warnings.
- Module labels inside diagrams: `text-xs uppercase tracking-wider`.
- Name modules with domain terms ("the Order intake module"), not class names.
- Write gains in codebase-design terms, not "cleaner" or "easier to maintain".

## Top recommendation

One larger card: the candidate's name, one sentence on why, and a link to its card.
