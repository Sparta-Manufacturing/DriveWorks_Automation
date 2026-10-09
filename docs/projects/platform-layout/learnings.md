# DW Platform Layout (and Platform Bolts): learnings

Dated findings about this project's rules, form and models. **Add new entries at the top.** Cross-project lessons go in [../../learnings.md](../../learnings.md); when an entry here teaches something that applies elsewhere, end it with an "Applies elsewhere:" line and add a short pattern there.

Related: [../inputs/platform-layout-inputs.md](../inputs/platform-layout-inputs.md), [../inputs/platform-bolts-inputs.md](../inputs/platform-bolts-inputs.md). Children: [../platform-straight/learnings.md](../platform-straight/learnings.md), [../platform-picking/learnings.md](../platform-picking/learnings.md), [../handrails/learnings.md](../handrails/learnings.md), [../handrails-outside/learnings.md](../handrails-outside/learnings.md).

---

## 2026-10-01: Platform Layout and Platform Bolts, read for the layout-app table

- **The design, as the user described it.** DW Platform Layout is the parent of all the platform projects.
  - It is mainly a big table plus empty assemblies that capture what the user does in the hosted Platform - Straight and Platform - Picking forms.
  - At release it loops through its tables and generates each platform, each handrail, and the bolts between shipping assemblies. It puts the platforms into SAs and the SAs into the top level.
  - The handrail logic still inside Straight and Picking is **inactive on purpose**, because the handrails must sit outside the SAs.
- **Platforms come back as rows.** The child's close macros run `RunFromSpartaChild…` in Layout with the child's `ListToPlatform` pipe list. Layout swaps `|` for `,` and stores it as one `PlatformList` row, so a comma inside a value shifts the columns.
- **`BinBackHeight` looks up a column that `PlatformList` doesn't have:** it has `BinBackWidth`. So Picking platforms may lose that value on every release, because release refreshes each platform in Edit mode.
- **Layout has no coordinates.** Platforms are placed only by coincident mates between connected zone planes and faces, and every Top plane is level. The overall footprint has to be worked out from the platform sizes and connections.
- **Assembly-number counters exist only for SAs 1–9.** New platforms in SAs 10–15 all get 100 × SA + 1. The saved list already has two platforms numbered 1101 in SA 11.
- **Sandbox registration:** Layout, Straight, Picking and Bolts are hidden and deployed, and DW HandRails is deployed. DW HandRails outside is `Deployed=False`, although Layout hosts it whenever Outside Railing is on.
- **Debug exports to a personal folder.** Layout's railing loop and Straight's close macros write text files to `C:\Users\oligod\OneDrive - Sparta Manufacturing\Desktop\text\` on every release (4 rules in each project).
- **What Layout sends the railings** (duplicate `OverwriteRailingHeight` rows, "Railing" falling back to Handrail, "Long" corners) is in [../handrails/learnings.md](../handrails/learnings.md).
- **Its `DWPlatformLayoutData` and `EquipmentListExport` SQL documents store a login in plain text** (see [../../learnings.md](../../learnings.md), 2026-10-02).
- **Applies elsewhere:**
  - A hosted child can send values back.
  - Host input tables can set child constants.
  - Titan's table functions.

  All three are in [../../learnings.md](../../learnings.md) (2026-10-01).
- The full tables are in [../inputs/platform-layout-inputs.md](../inputs/platform-layout-inputs.md) and [../inputs/platform-bolts-inputs.md](../inputs/platform-bolts-inputs.md).
