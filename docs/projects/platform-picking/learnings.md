# DW Platform - Picking: learnings

Dated findings about this project's rules, form and models. **Add new entries at the top.** Cross-project lessons go in [../../learnings.md](../../learnings.md); when an entry here teaches something that applies elsewhere, end it with an "Applies elsewhere:" line and add a short pattern there.

Related: [../inputs/platform-picking-inputs.md](../inputs/platform-picking-inputs.md) (every input). Parent: [../platform-layout/learnings.md](../platform-layout/learnings.md). Sibling: [../platform-straight/learnings.md](../platform-straight/learnings.md), which holds the points shared by both platforms.

---

## 2026-10-01: Read for the layout-app table (with Platform - Straight)

- **The shared points** are in [../platform-straight/learnings.md](../platform-straight/learnings.md):
  - the hosted spec is never saved;
  - zone planes mark zone centres;
  - the row carries the typed totals;
  - inputs that drive nothing;
  - text-box Min/Max isn't enforced.
- **A 36 in Platform zone is always modelled at 36.4375 in** in Picking (in Straight, only with Grating).
- **Copied rules that point at nothing:**
  - Picking's `WOPrefix` and `WorkOrder` defaults read constants that only Straight has.
  - Picking's "generated" email attaches `-WithRailings <id>.pdf`, while the triggered action waits for `-WithBolts`.
- **Layout may lose `BinBackHeight` on every release** (its lookup names a column `PlatformList` doesn't have; see [../platform-layout/learnings.md](../platform-layout/learnings.md)).
- The full table is in [../inputs/platform-picking-inputs.md](../inputs/platform-picking-inputs.md).
