---
name: credit-account-adapter-facade
description: >
  Reviews Gearbox-style credit account adapters and multicall facades: recipient
  force, path allowlists, phantom tokens, gateway claim caps, LP oracles.
  Use when auditing credit managers, integration adapters, zappers, or
  partial-liquidation bots for leveraged DeFi accounts.
---

# Credit-account adapter facade (Gearbox class)

## When to use

- Protocol holds user positions in **credit accounts** (smart wallets / CAs)
- External DeFi is reached only via **adapters** called from a facade/multicall
- Liquidations use bots with limited call permissions

## Hardened paradigm (expect this)

```text
creditFacadeOnly / botMulticall
  → adapter whitelist (target + selector + path)
  → force recipient = credit account (ignore user `to`)
  → exact PATH lengths / rebuild external calldata
  → approve hygiene
  → full collateral check (HF ≥ 1) after mutators
```

## Review checklist

### Adapter call data

- [ ] Can attacker set `recipient` / `to` / `receiver` away from CA?
- [ ] UniV2/V3 path length exact? exactOut approves **last** token?
- [ ] External `SwapData` fields stripped/rebuilt (Pendle-class)?
- [ ] Hook data empty / allowlisted (UniV4)?

### Accounting

- [ ] Phantom token valuation: `max(balance, estimate)` — donations real?
- [ ] Gateway claims: **per-user pending** caps (not shared pool free-for-all)?
- [ ] Liquidation bot: fee from balance delta; post-check HF; permission bits exact?

### Oracles (integrations)

- [ ] LP/ERC4626 feeds: lowerBound + deviation window?
- [ ] Redstone/Pyth: signed payloads; unprivileged manip?
- [ ] Third-party **data** wrong vs **manipulable** feed (program OOS rules)

## High-frequency rejects

| Claim | Why |
|-------|-----|
| “I can pass malicious path” | Often exact length + token allowlist |
| “Soft-liq drains healthy accounts” | User opted into bot; FCC still required |
| “Oracle wrong price” | Incorrect third-party data OOS unless manipulation path |
| Historical Uni path parser class | Fixed by exact PATH + last-token approve |

## Promote only if

Unprivileged (or liquidator without extra privilege) can:

1. Force tokens out of a **victim** CA, or  
2. Inflate collateral valuation beyond real redeemable assets **and** borrow against it, or  
3. Claim another user’s gateway/pending yield permanently

## References

- Gearbox integrations-v3 / oracles-v3 / bots-v3 hunts (security-research 2026-07)
- MixBytes bots audit classes (soft-liq, safe prices)
