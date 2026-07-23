---
name: cctp-destination-caller
description: >
  Reviews CCTP (Circle Cross-Chain Transfer Protocol) integrations for inventory
  desync: destinationCaller binding, Nonce already used catch paths, FAST fees,
  planned vs measured mint amounts. Use when auditing Vault.rebalanceMint-style
  CCTP burn/mint inventory accounting.
---

# CCTP destinationCaller + mint inventory

## When to use

- Cross-chain vault rebalance via CCTP `depositForBurn` / `receiveMessage`
- Code credits inventory on mint success **and** on certain catch paths
- FAST transfer fees or partial mint amounts exist

## Bug pattern (theoretical)

```solidity
// SUCCESS path — good: measure actual mint
amount = balanceAfter - balanceBefore;
finishMint(amount);

// CATCH "Nonce already used" — dangerous if unprivileged can force it:
// credits planned data.amount without measuring balance delta
finishMint(data.amount); // may overstate if fee/partial
```

If an attacker can frontrun `receiveMessage` and consume the CCTP nonce, the
integrator might credit full planned amount while tokens never arrive (or arrive short).

## Kill criteria (Orderly 2026 lesson)

Unprivileged frontrun is **closed** when:

```text
depositForBurn(..., destinationCaller = mintChainVault)
```

Only the vault can call `receiveMessage` for that burn. Catch path then requires
**trusted** double-delivery (privileged CrossChainManager), which is typically OOS.

## Review checklist

- [ ] Who is `destinationCaller` on burn? (zero = permissionless receive)
- [ ] Success path: balance delta or CCTP return value?
- [ ] Catch paths: which errors credit inventory? which amounts?
- [ ] FAST vs NORMAL fee: is planned amount gross or net?
- [ ] Can non-vault call `receiveMessage` for the message?
- [ ] Does `finishMint` increase withdrawable inventory / shares?

## Promote only if

1. `destinationCaller` is zero or attacker-controlled, **and**  
2. Catch/success credits **more** than tokens received, **and**  
3. That inventory is user-withdrawable or causes insolvency  

## References

- Orderly Vault CCTP candidate kill (security-research 2026-07-22)
- Circle CCTP `destinationCaller` semantics
