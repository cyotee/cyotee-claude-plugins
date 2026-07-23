---
name: l2-bridge-message-auth
description: >
  Reviews L2 token bridges and message services: escrow balance deltas, remote
  sender checks, claim bitmaps, rolling hashes, rollup finalization public
  inputs. Use for Linea-class TokenBridge/MessageService/LineaRollup reviews.
---

# L2 bridge + message auth

## When to use

- Canonical token bridges with L1↔L2 escrow
- Message services that deliver arbitrary payloads after finalization
- Rollup contracts that anchor state roots / shnarfs / forced txs

## Bridge checklist

- [ ] Escrow uses **balance delta** (not raw `amount`) for fee-on-transfer
- [ ] `completeBridging` requires authenticated message service + expected remote sender
- [ ] Transient `msg.sender` / sender context cannot be spoofed mid-claim
- [ ] Mapping token addresses consistent both directions + chainId
- [ ] Reentrancy: claim ↔ bridge order + guards

## Message service checklist

- [ ] Claim bitmap / status prevents double-claim
- [ ] V1 vs V2 store separation if migrated
- [ ] L1→L2 injection requires role + rolling-hash continuity
- [ ] Empty/depth-0 merkle roots cannot free-claim

## Finalization checklist (entry auth, not circuit math)

- [ ] `finalize*` is **operator-only** (or equivalent)
- [ ] Parent state root + sequential block/shnarf linkage
- [ ] Public input binds: blocks, roots, depth, rolling hashes, forced-tx ends, chain config
- [ ] Verifier must return true; failed verify reverts whole finalize (atomicity)
- [ ] Effects-before-verify is OK **only** if full tx reverts on fail

## Known false positives

| Pattern | Typical triage |
|---------|----------------|
| “Withdrawal availability over yield” | Linea-class known design (e.g. 1316) |
| “Operator can finalize bad state” | Privileged unless proof check broken |
| Event `from` ≠ hash `from` in yield | Often intentional tested behavior |

## Promote only if

Unprivileged (or weakly privileged beyond documented operator) can:

- Double-mint bridged tokens  
- Claim same message twice  
- Finalize invalid root without valid proof acceptance  

## References

- Linea TokenBridge / MessageService / LineaRollup hunts (security-research 2026-07)
