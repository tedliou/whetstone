---
name: codebase-design
description: "Deep-module vocabulary: module, interface, seam, adapter, depth. Use when designing an interface, placing a seam, or improving testability."
---

# Codebase design

Aim for deep modules: a lot of behaviour behind a small interface, placed at a clean seam, tested through that interface. Callers get leverage, maintainers get locality.

## Terms

Use these words exactly, in reasoning and in output.

| Term | Meaning | Not |
|---|---|---|
| module | Anything with an interface and an implementation, at any scale: function, class, package, or a slice across tiers. | component, service, unit |
| interface | Everything a caller must know to use the module: types, plus invariants, call order, error modes, required config, performance. | API, signature (these cover only the types) |
| implementation | The code inside a module. | |
| depth | Behaviour a caller can use per unit of interface they must learn. Deep: much behaviour, small interface. Shallow: interface nearly as big as the implementation. | line-count ratio |
| seam | Where a module's interface lives; a place where behaviour can change without editing there. Where to put it is its own decision. | boundary |
| adapter | A concrete thing that fills the interface at a seam. Names a role, not a size. | |
| leverage | What callers gain from depth: one implementation serves N callers and M tests. | |
| locality | What maintainers gain from depth: change, bugs, and verification sit in one place. | |

```
deep                          shallow
+-------------+               +-----------------------------+
| small iface |               |      large interface        |
+-------------+               +-----------------------------+
|             |               |  thin pass-through impl     |
|  lots of    |               +-----------------------------+
|  behaviour  |
+-------------+
```

## Principles

- Depth belongs to the interface. A deep module may be built from small swappable parts inside; they are internal seams, used by its own tests, and stay out of the interface.
- Deletion test: imagine deleting the module. If its complexity vanishes, it was a pass-through. If the complexity reappears in every caller, it earns its place.
- The interface is the test surface. Callers and tests cross the same seam. Needing to test past the interface means the module has the wrong shape.
- One adapter is a hypothetical seam; two adapters (usually production and test) make it real. Add a seam only where something actually varies.
- Testable interfaces take their dependencies as arguments instead of constructing them, return results instead of mutating inputs, and have few methods and few parameters.

## Dependencies decide how to deepen

Before merging a cluster of shallow modules into one deep module, sort its dependencies. The category decides how the deep module is tested.

| Category | Example | Approach |
|---|---|---|
| In-process | pure logic, in-memory state | Merge and test through the new interface. No adapter. |
| Local stand-in exists | PGLite for Postgres, in-memory filesystem | Merge; run the stand-in in tests. The seam stays internal. |
| Remote, owned by you | your own service or internal API | Define a port (an interface) at the seam. Production uses an HTTP, gRPC, or queue adapter; tests use an in-memory one. |
| External, not yours | Stripe, Twilio | Inject it as a port; tests use a mock adapter. |

Replace tests, do not layer them. Once tests exist at the deep module's interface, delete the old unit tests on the shallow modules it absorbed. New tests assert observable outcomes through the interface, so they survive internal refactors.

## Comparing alternative interfaces

When the user wants to see different shapes for one interface, follow [design-it-twice.md](design-it-twice.md).
