---
name: 0x-settler-settlement-auth
description: >
  Reviews 0x Settler multicall settlement: Permit2 payer/operator/witness transient
  locks, AllowanceHolder ephemeral allowances, RFQ/meta-txn VIP ordering, UniV3
  callback auth. Use when auditing 0x Settler, BridgeSettler, or similar
  non-custodial DEX settlement multicalls.
---

# 0x Settler settlement auth

## When to use

- `0xProject/0x-settler` or forks
- Multicall actions: VIP transfer, UniV3/V4, Balancer, RFQ, BASIC, bridges
- Meta-transactions and intent solvers

## Auth models

| Mode | Payer binding |
|------|----------------|
| Taker | `msg.sender` payer |
| Meta-txn | Permit2 **witness** over actions + slippage; first action must spend VIP |
| Intent | Witness over slippage; solver allowlist |

## Transient locks (must hold)

- **payer** — reentrancy + `_msgSender` for pulls  
- **operator** — callback auth (pool/vault must match)  
- **witness** — meta spend-once  

Callback packaging: `operator | callbackPtr | selector` in one tstore word; consume requires match then zero.

## AllowanceHolder

- Key `(operator, owner, token)` ephemeral  
- `exec` appends true sender (ERC-2771 style)  
- Probes `balanceOf` to block ERC20 confused deputy  
- Settler stubs `balanceOf` so AH does not treat it as ERC20  

## Action checklist

- [ ] BASIC: blocked targets include Permit2, AH, chain extras; max approve residual?
- [ ] RFQ: Consideration witness binds token/amount/counterparty/partialFill
- [ ] UniV3 VIP: pool CREATE2-derived; pay only via operator callback
- [ ] Meta: first action clears witness via `_transferFrom`
- [ ] Proportional `~amount` only where intended (not Feature 3 meta)

## Program-specific OOS (0x Immunefi)

Loss from **bad action encoding**, slip misuse, BASIC to attacker contracts is often **explicitly OOS**. Prefer unauthorized spend of **victim** allowance/permit.

## Historical regression

TOB UniV3+BASIC meta-txn frontrun: ensure callback operator gate still present; repo tests expect frontrun revert.

## References

- security-research: `programs/immunefi-0x-settler/notes/patterns-for-skills.md`
