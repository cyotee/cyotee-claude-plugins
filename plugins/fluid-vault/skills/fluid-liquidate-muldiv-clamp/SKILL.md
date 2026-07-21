---
name: fluid-liquidate-muldiv-clamp
description: >
  Reviews Fluid (Instadapp) vault liquidate paths for inverted integer mul/div
  when clamping collateral to a debt amount. Use when auditing Fluid vaultT1 or
  vaultTypesCommon liquidation, or any protocol that scales collateral as
  col * (debt/actualDebt) in Solidity integer math.
---

# Fluid liquidate mul/div clamp

## When to use

- Reviewing **Fluid** vault liquidation (`vaultT1`, T2–T4 common modules)
- Any liquidate/repay path that **clamps** output collateral when actual debt converted &gt; user-supplied debt amount
- Checking for **Vault vs Liquidity accounting desync** after partial liquidations

## Bug pattern

Incorrect scaling of collateral when reducing liquidated debt to a caller-supplied cap:

```solidity
// WRONG in integer math when debtAmt < actualDebtAmt:
// quotient is 0 → wipes collateral amount
actualColAmt = actualColAmt * (debtAmt / actualDebtAmt);
actualDebtAmt = debtAmt;

// RIGHT:
actualColAmt = (actualColAmt * debtAmt) / actualDebtAmt;
actualDebtAmt = debtAmt;
```

Solidity floor division means `debtAmt / actualDebtAmt == 0` whenever `debtAmt < actualDebtAmt`.

## Why it matters

If the branch is reachable:

1. **With min-out = 0** (`colPerUnitDebt == 0`): liquidator may pay debt and receive **0 coll** while vault **internal totals** still subtract full raw liquidated col/debt → books desync from Liquidity layer.
2. **With min-out &gt; 0**: often reverts (DoS on edge amounts) rather than theft.

If the branch is **dead** under the protocol’s floor math (e.g. raw path guarantees `actualDebtAmt <= debtAmt`), impact may be zero — **always prove reachability**.

## Review checklist

- [ ] Locate all `actualDebtAmt > debtAmt` (or similar) clamps
- [ ] Confirm mul/div order on collateral scale
- [ ] Check whether vault storage totals use **raw** or **clamped** amounts
- [ ] Check Liquidity/pool operate amounts match storage deltas
- [ ] Check min-out / slippage params that force revert vs allow zero coll
- [ ] Fuzz near full liquidatable debt and absorb/multi-tick paths
- [ ] Confirm same pattern in all vault types (T1 vs shared module)

## PoC hints

1. Fixture: open position, move oracle to liquidatable.
2. Binary-search `debtAmt` near full liquidatable amount.
3. Call `liquidate(debtAmt, 0, liquidator, false)` (or protocol equivalent).
4. Assert either:
   - branch never taken under realistic math, or
   - `actualCol` zeroed / vault totals ≠ Liquidity balances after success.

## Related files (Fluid public repo examples)

- `contracts/protocols/vault/vaultT1/coreModule/main.sol` — liquidate clamp
- `contracts/protocols/vault/vaultTypesCommon/coreModule/main.sol` — shared path

## References

- Wave-1 candidate: Instadapp Fluid vault liquidate integer div (security-research 2026-07-21)
