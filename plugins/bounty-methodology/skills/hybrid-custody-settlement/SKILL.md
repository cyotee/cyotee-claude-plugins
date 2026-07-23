---
name: hybrid-custody-settlement
description: >
  Reviews hybrid on-chain custody / off-chain matching systems (Synthetix-style
  deposit contracts): multi-stage withdrawals, role quorums, int256 balances,
  CoW ERC-1271, Permit2 deposits. Use when auditing custody layers listed
  separately from DEX monorepos.
---

# Hybrid custody settlement

## When to use

- Immunefi assets are **only** deposit/registry/lens contracts
- Withdrawal is multi-party: user cannot self-exit fully
- Balances may be **signed** or updated by off-chain PnL

## Architecture pattern

```text
User deposit (Permit2 / transfer)
    → on-chain credit (_userBalance, often int256)
User request cancel (own Requested only)
RELAYER request withdrawal
WATCHER quorum validate
TELLER disburse (transfer out)
```

PermissionsRegistry may be **orthogonal** — always `grep` whether custody reads it.

## Review checklist

### Auth / stages

- [ ] Map roles: who `request` / `validate` / `disburse` / `dispute`
- [ ] Can user force disburse without roles? (usually no → not Critical freeze alone)
- [ ] One-active-withdrawal invariants; expiry for Requested vs Validated/Disputed
- [ ] Finalize-before-transfer: does failed ERC20 transfer revert whole tx?

### Balance model

- [ ] Is `_userBalance` checked on withdraw, or purely off-chain PnL?
- [ ] `int256` without floor check is often **by design** — not auto-Critical
- [ ] Deposit path: credit-before-transfer + reentrancy guard; FoT if exotic collateral allowed

### CoW / settlement envelopes

- [ ] ERC-1271: forced receiver, sell/buy allowlists, digest binding
- [ ] ECDSA signer must hold trader role
- [ ] Fields skipped in digest (`appData`, fees) = **trader-role trust**, not public

### Permit2

- [ ] Owner must be `msg.sender` for deposit permits
- [ ] Token/amount/deadline validated against credit

## Kill / promote guide

| Finding shape | Likely triage |
|---------------|---------------|
| “Users can’t withdraw without operators” | Centralization OOS |
| “Operator can drain with 3 roles colluding” | Privileged OOS |
| Unprivileged double-claim / cancel race / permit theft | **Promote** |
| Registry grant without custody consumer | No impact unless coupled |

## References

- Synthetix mainnet DepositContract + PermissionsRegistry (Immunefi 2026 custody scope)
- security-research: `programs/immunefi-synthetix/notes/patterns-for-skills.md`
