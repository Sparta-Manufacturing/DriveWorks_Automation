# DW Select Project: learnings

Dated findings about this project's rules, form and models. **Add new entries at the top.** Cross-project lessons go in [../../learnings.md](../../learnings.md); when an entry here teaches something that applies elsewhere, end it with an "Applies elsewhere:" line and add a short pattern there.

Related: [../inputs/select-inputs.md](../inputs/select-inputs.md) (every input). Opens: [../order/learnings.md](../order/learnings.md).

---

## 2026-10-02: Read for the layout-app table (with DW Order Project)

- **Why Select and Order exist, from the user:** they are about the user interface and data storage, not specific equipment. The full statement and the SQL hierarchy are in [../order/learnings.md](../order/learnings.md).
- **Order's `RunFromSpartaChildClose` drives Select's `DisplayEquipmentInterface`** rather than Order's own host control (an Order bug; see its file).
- **Its `AddNewTeamInSQL` SQL document stores a login in plain text** (see [../../learnings.md](../../learnings.md), 2026-10-02).
- The full table is in [../inputs/select-inputs.md](../inputs/select-inputs.md).
