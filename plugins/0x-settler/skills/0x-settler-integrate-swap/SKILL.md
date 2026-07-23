---
name: 0x-settler-integrate-swap
description: >
  Implement swaps against 0x Settler multicalls: taker flow, Permit2/AllowanceHolder VIP
  funding, action ordering, minOut, blocked targets, meta-txn and intent modes. Use when
  building a router, DEX aggregator client, or smart contract that settles via 0x Settler.
---

# Integrate swaps with 0x Settler

## Conceptual overview

Settler is a **non-custodial multicall settler**: sell tokens enter via a VIP transfer (Permit2 or AllowanceHolder), middle actions route through DEX/RFQ adapters, and the user receives `buyToken` subject to `minOut`. Do not treat it as a long-term custody vault.

## Happy path (taker / `msg.sender` is payer)

```text
1. User ERC20-approves Permit2 (or uses AllowanceHolder exec)
2. User (or router) calls Settler with:
   - VIP action 0: transfer sellToken → Settler (Permit2 or AH)
   - Action 1..n: swaps (UniV3 VIP, RFQ, BASIC to allowed targets, …)
   - Final: send remaining buyToken to recipient ≥ minOut
3. Transient payer/operator/witness locks clear by end of tx
```

### Implementation checklist

- [ ] Resolve Settler address from **Deployer** feature registry (taker feature id typically `2`); `ownerOf` revert ⇒ feature paused
- [ ] Prefer **typed VIP actions** over open BASIC when possible
- [ ] Encode sell amount; optional proportional `~amount < 10000` = bps of balance (taker / intent-bridge only — **not** meta Feature 3)
- [ ] Set **minOut** on buy token; never rely on Settler holding residual for later
- [ ] Chain-specific blocked BASIC targets: always exclude Permit2, AllowanceHolder, and documented extras

## Funding modes

| Mode | How funds enter | Integrator notes |
|------|-----------------|------------------|
| **Permit2 VIP** | User signs Permit2; Settler pulls | Use `skill:permit2-signature-transfer` / allowance flow |
| **AllowanceHolder** | User `AH.exec` with empty Permit2 sig, nonce 0 | Deadline checked in Settler; AH keys `(operator, owner, token)` |
| **Meta-txn** | Relayer submits; witness binds actions + slippage | **First action must VIP-spend** and clear witness |
| **Intent** | Solver allowlist; witness binds slippage only | Solver cannot change signed Slippage fields |

See also: `skill:0x-settler-settlement-auth` (security model of locks).

## Action composition rules

1. **VIP first** when using meta/witness binding.  
2. **Callbacks** (UniV3, etc.): Settler sets `operator` to the pool; only that operator may trigger pay.  
3. **BASIC**: arbitrary call + optional amount patch + max approve — only to **allowed** targets; residual approve is a UX/security footgun for users.  
4. **Bridges** (Across/LZ/CCIP/Relay): often override amount to **full Settler balance**; nested SETTLER_SWAP must hit Deployer-registered Settler.  
5. **RFQ**: maker Permit2 witness must bind token, amount, counterparty, partialFill.

## Client-side pseudo-flow (taker)

```text
// Pseudocode — adapt to chain ABI / SDK
actions = [
  encodeTransferFromVIP(sellToken, amount),      // Permit2 or AH
  encodeUniswapV3VIP(path, …),                   // or other adapters
]
call Settler.execute(actions, buyToken, minOut, recipient)
// require buyToken.balanceOf(recipient) increased ≥ minOut (or use return data if ABI exposes)
```

## Footguns for integrators

| Footgun | Correct behavior |
|---------|------------------|
| BASIC to Permit2/AH | Blocked or catastrophic; never encode |
| Meta without leading VIP | Witness never clears; spend fails / auth broken |
| Assuming stuck dust is recoverable | User self-risk; not protocol custody |
| Wrong feature ID / paused Deployer | Preflight `ownerOf(featureId)` |
| Intent solver rewriting slip | Must respect signed Slippage |

## Testing

- Unit: mock Permit2 pull + single-hop VIP + minOut boundary  
- Fork: real pool CREATE2 address for UniV3 VIP on target chain  
- Meta: relayer cannot change action list without invalidating witness  
- Negative: BASIC to Permit2 reverts / is rejected  

## See also

- `skill:0x-settler-settlement-auth` — auth/locks security  
- `skill:permit2-allowance-flow`, `skill:permit2-signature-transfer`  
- security-research patterns: `programs/immunefi-0x-settler/notes/patterns-for-skills.md`
