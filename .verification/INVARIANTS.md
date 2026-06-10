# Project Invariants

The canonical list of system-wide guarantees: properties this system must
always hold, and actions it must never take. Each invariant is enforced by one
or more contracts in `contracts/`.

This file is a fast lookup: scan the headlines, find the relevant invariant,
click through to the contracts that enforce it.

Invariants are added carefully and removed almost never. They are the
"constitutional law" of the codebase.

State each invariant as an "always" or a "never," whichever reads more clearly
and gives the sharpest, most checkable violation condition. The two forms are
logically equivalent; pick the one a reader understands fastest.

---

## Format

```
## INV-NNN: <one-sentence statement of the invariant>
- Enforced by: contracts/NNNN-name.md, contracts/NNNN-name.md
- Why it exists: <one paragraph>
- Status: active | deprecated
```

---

## Active invariants

<None yet. Add as the project develops.>

---

## Deprecated invariants

<None yet. When an invariant is deprecated, move it here with a date and reason.>
