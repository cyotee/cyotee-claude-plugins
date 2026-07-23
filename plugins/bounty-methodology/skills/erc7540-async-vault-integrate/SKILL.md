---
name: erc7540-async-vault-integrate
description: >
  Integrate with ERC-7540-style async deposit/redeem vaults: request → manager
  approve → claim, controllers/operators, NAV freshness for quotes, idle reserves.
  Use when building frontends, keepers, or contracts that deposit/redeem into
  async funds (PortfolioVault-class, Enzyme Onyx queues, similar).
---

# Integrate ERC-7540 / async vaults

## Conceptual overview

Unlike ERC-4626 instant mint/redeem, async vaults **freeze share price at approval**:

```text
Deposit:  requestDeposit(assets) → [manager] approveDeposit → deposit/mint claim shares
Redeem:   requestRedeem(shares)  → [manager] approveRedemption → redeem/withdraw claim assets
```

`convertToShares` / `sharePrice` often read **last finalized NAV**, not live NAV. Do not quote them as a real-time oracle after invalidation.

## Happy paths

### Deposit (shareholder)

```text
1. Ensure user has SHAREHOLDER / whitelist role if gated
2. ERC20 approve vault (or permit) for assets
3. requestDeposit(assets, controller, owner)
   - assets move to vault; pendingDeposit[controller] += assets
4. Off-chain / keeper: wait for manager approveDeposit(controller, assets')
   - price locked: shares minted to vault; claimableDeposit* set
5. deposit(assets') or mint(shares') to claim to receiver
6. Optional: cancelDepositRequest only while still pending (pre-approve)
```

### Redeem

```text
1. requestRedeem(shares, controller, owner) — shares locked on vault
2. Manager approveRedemption — burns shares, reserves claimable assets from idle
3. redeem/withdraw claim assets to receiver
4. cancelRedeemRequest only while pending
```

### Operator pattern

- Owner may `setOperator(operator, true)` so a keeper can call request/claim on their behalf  
- **Default UX should not set untrusted operators** — same trust model as ERC20 approve  

## NAV-aware quoting

| Signal | Integrator action |
|--------|-------------------|
| NAV computation mid-cycle / invalidated | Disable deposit/redeem **approval** quotes; show “NAV updating” |
| `lastNav == 0` / ZeroNav | Bootstrap/seed required; do not promise mint |
| `maxNavAge` exceeded | Treat price as stale until `updateNav` finalizes |
| Holdings nonce / calculator version change | Mid-cycle restart — wait for finalize |

Backend/keepers that call `approveDeposit`/`approveRedemption` must enforce **fresh NAV** (idle, nonce, version, age). See `skill:async-vault-nav-freshness`.

## Idle liquidity

```text
idle ≈ balance − pendingDeposits − claimableRedeems
```

- Manager fund/buy/deploy must use **idle**, not raw balance  
- Integrators should not assume pending deposit USDC is investable  

## Footguns

| Footgun | Correct behavior |
|---------|------------------|
| Treat convertToShares as live TWAP | Use only after fresh NAV finalize; document staleness |
| Claim before approve | Reverts / zero claimable |
| minOut=0 on related swaps elsewhere | Separate from vault claim algebra |
| Controller ≠ owner without operator | Only controller/operator can claim |
| Partial claim dust | Floor math may leave dust; claim full when possible |
| Open vault sale offers vs NAV | Backend should block share approvals while vault is active seller (if protocol uses loan NFT listings) |

## Testing

- Request → approve → full claim; counters zero  
- Partial claim series; remaining claimable consistent  
- Cancel while pending restores assets/shares  
- Approve after invalidate reverts until re-NAV  
- Operator claim; unauthorized stranger reverts  

## See also

- `skill:async-vault-nav-freshness` — security invalidate map  
- security-research: Tare PortfolioVault / Enzyme Onyx patterns  
