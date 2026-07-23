---
name: async-vault-nav-freshness
description: >
  Reviews ERC-7540 / async deposit-redeem vaults with on-chain NAV: invalidate
  maps, ownership nonces, calculator versions, claim algebra, idle reservations.
  Use for PortfolioVault-style funds, Enzyme Onyx queues, or any async vault
  that freezes share price at approval.
---

# Async vault NAV freshness (ERC-7540 class)

## When to use

- `requestDeposit` / `requestRedeem` + manager `approve*` + claim
- NAV computed in batches from loan/position ledgers
- Share price uses last finalized NAV, not spot balances

## Freshness conjunction checklist

Any mutator of NAV inputs must hit **one** of:

1. Explicit `_invalidateNav()` / zero `lastNavUpdate`
2. Holdings **nonce** bump (NFT set change)
3. Calculator **config version** bump
4. Be proven **NAV-neutral** (1:1 offset in finalize formula)

### Two-signal pattern

| Input class | Typical signal |
|-------------|----------------|
| NFT ownership set | `ownershipNonce` |
| Idle USDC, curated list, ledger cashflows | explicit invalidate |
| Discount/portfolio factors | `configurationVersion` |

Do **not** assume nonce covers waterfall/ledger changes.

## ERC-7540 claim algebra

- Mint/burn shares at **approve** (price lock)
- Claim uses floor proportional math: require `assets > 0 && shares > 0`
- Fuzz: `Σ pending` / `Σ claimable` vs globals used in NAV finalize
- Full claim must clear both sides (no permanent XOR strand)

## Idle reservation

```text
idleLiquidity = balance − pendingDeposit − claimableRedeem
```

All capital-deploy paths must use **idle**, not raw `balanceOf`, or redeem reserves can be double-spent.

## High-frequency false positives

| Pattern | Why often reject |
|---------|------------------|
| USDC donation without invalidate | Intentional anti-DoS; multi-shareholder threat model dependent |
| Pending open sale offer vs NAV | Ops/backend gate; often design-ack |
| DPD drift within maxNavAge | Documented staleness bound |
| Zero-NAV bootstrap | Known; seed donation required |
| Dead shares price bias early | Documented |

## Review order

1. List every vault mutator → map to invalidate/nonce/version  
2. Trace `approveDeposit` / `approveRedemption` against `_requireFreshNav`  
3. Trace claim/cancel counters  
4. Trace collectCashflows / fund / buy — curated-list gates  
5. Exchange lock interaction (listed loans: unlocker withdraw routing)

## References

- Strata-adjacent Tare PortfolioVault (Sherlock 2026) patterns  
- Enzyme Onyx ERC7540-like queues  
- security-research: `programs/sherlock-tare/notes/patterns-for-skills.md`
