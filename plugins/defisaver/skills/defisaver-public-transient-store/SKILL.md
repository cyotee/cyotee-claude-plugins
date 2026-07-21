---
name: defisaver-public-transient-store
description: >
  Reviews DeFi Saver (and similar recipe executors) for public transient/persistent
  temp stores used by triggers, checkers, and exchange callbacks. Use when auditing
  DFS TransientStorage, BytesTransientStorage, ratio checkers, LimitSell, or
  CurveUsd/LlamaLend swap intent buses.
---

# DeFi Saver public transient stores

## When to use

- Auditing **recipe/strategy** executors that share temp storage across actions
- **Ratio checkers** that read start values written by triggers
- **Callback swappers** that read exchange data from a public bytes store

## Bug classes

1. **Cross-tx pollution** — if store is a normal mapping (not true EIP-1153 transient), leftover keys affect later txs.
2. **Mid-tx overwrite** — public `set*` allows nested calls (reentrancy/hooks) to poison keys before checkers/swappers run.
3. **Inconsistent clear** — L1 vs L2 actions differ on clearing price/ratio keys after use.

## Review checklist

- [ ] Is storage true `tstore`/`tload` or a public mapping?
- [ ] Who can write? (public / only executor)
- [ ] Which actions write which keys? Which read?
- [ ] Is there a reentrancy host (ERC777, callbacks, nested recipes)?
- [ ] Do production strategies always re-write keys before read?
- [ ] Compare L1 vs L2 variants for missing clears

## PoC hints

- Prefer a **callback token** or mock action that, mid-recipe, calls public `setBytes32` / `setBytesTransiently`.
- Show checker pass after health worsened, or swap fill at attacker `minPrice`.
- Kill if no path without already controlling the full recipe callData.

## References

- DFS `TransientStorage.sol`, `BytesTransientStorage.sol`
- Triggers + `*RatioCheck` actions; `LimitSell` / `LimitSellL2`
