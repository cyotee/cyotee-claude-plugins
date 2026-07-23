---
name: cctp-vault-rebalance-integrate
description: >
  Integrate Circle CCTP for vault/inventory rebalance: depositForBurn, receiveMessage,
  destinationCaller binding, FAST fees, planned vs measured mint amounts. Use when
  building cross-chain vaults, inventory ledgers, or rebalance managers on CCTP.
---

# Integrate CCTP vault rebalance

## Conceptual overview

CCTP moves USDC (or supported stable) across domains:

```text
Source vault:  depositForBurn(amount, dstDomain, mintRecipient, token, destinationCaller, maxFee, finality)
Destination:   receiveMessage(message, attestation) → mint to mintRecipient
Your ledger:   credit inventory only from measured mint (or trusted fail handling)
```

## Happy path (vault-managed rebalance)

```text
1. Source chain ledger marks rebalance Pending; vault burns via TokenMessenger
2. Set mintRecipient = destination vault
3. Set destinationCaller = destination vault  // CRITICAL
4. Attestation service signs message
5. Destination vault (only) calls receiveMessage inside rebalanceMint
6. Credit inventory with balanceAfter - balanceBefore (measured)
7. Mark rebalance success; enable withdraws against new inventory
```

## destinationCaller (must get right)

| Setting | Effect |
|---------|--------|
| **destinationCaller = dst vault** | Only vault can `receiveMessage` — blocks unprivileged frontrun of mint |
| **destinationCaller = 0** | Anyone can receiveMessage — integrator must not credit planned amount on race/error |

Security lesson: if catch-path credits **planned** `data.amount` on `"Nonce already used"`, attackers can only force that if they can call receiveMessage first. Binding destinationCaller to the vault closes that class. See `skill:cctp-destination-caller`.

## Amount / fee rules

- Prefer **measured mint**: `balanceOf(vault) after − before`  
- FAST paths may mint **less** than burn amount (fee) — never credit gross burn amount on success  
- NORMAL may require exact equality — enforce if your product assumes 1:1  

```solidity
// Pattern on destination vault (simplified)
uint256 before = token.balanceOf(address(this));
messageTransmitter.receiveMessage(message, attestation);
uint256 minted = token.balanceOf(address(this)) - before;
// credit ledger with minted — not the original planned burn amount
```

## Inventory ledger integration

If a separate VaultManager tracks `tokenBalanceOnchain`:

- [ ] Success finish uses **measured** amount  
- [ ] Fail path does **not** increase inventory  
- [ ] Catch paths: only credit if tokens actually arrived; prefer re-measure  
- [ ] Withdraw gating should prefer ledger + reconcile to `balanceOf`  

## Footguns

| Footgun | Fix |
|---------|-----|
| Credit `data.amount` on any catch | Measure balance or hard-fail |
| destinationCaller = 0 for convenience | Use vault address |
| Double finishMint without Pending guard | Status machine: Pending → Succ/Fail once |
| Assuming attestation is free | Keepers submit attestation; fund gas |
| Ignoring FAST fee | UX shows expected net; ledger uses net |

## Testing

- Unit: mock transmitter mints N < planned; ledger credits N  
- Unit: destinationCaller rejects non-vault receiveMessage  
- Fork: burn on domain A, mint on B, inventory + withdraw  
- Negative: double receiveMessage; nonce used; inventory not double-credited  

## See also

- `skill:cctp-destination-caller` — security triage for catch/credit bugs  
- Circle CCTP V2 TokenMessenger / MessageTransmitter docs  
- security-research: Orderly CCTP rebalance patterns (2026-07)  
