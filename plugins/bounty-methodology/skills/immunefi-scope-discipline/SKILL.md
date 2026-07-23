---
name: immunefi-scope-discipline
description: >
  Freezes Immunefi/contest scope before deep review: assets table vs monorepo,
  known issues, trusted roles, Primacy of Rules vs Impact, PoC seeding rules.
  Use when starting a bounty program, intake, or when a monorepo may be mostly OOS.
---

# Immunefi / contest scope discipline

## When to use

- Opening a new continuous or contest engagement
- Before hunting a large monorepo (Synthetix V3, Sky, Lido, Enzyme Blue)
- Triaging whether a “bug” is OOS trusted-role / known-issue / design-ack

## Lessons learned (2026 continuous pass)

1. **Listing assets ≠ whole GitHub org.** Synthetix SC scope was only custody proxies; the public V3 monorepo was mostly OOS. Always pin **listed contracts** (or their verified impl source).
2. **Narrow asset lists kill high-EV math.** Strata listed only cooldowns/depositor/oracles/utils — not CDO/Accounting/Tranche. Hunting OOS core wastes cycles.
3. **Known-issue catalogs are first-class.** Parallel (37 IDs), SSV (1299–1306), Alchemix (1250–1287), PCS (1291/1298) — refiles die in triage.
4. **Trust models dominate.** Tare/Strata/Alchemix: servicer/admin/curator discretion is intentional; only **cross-user / unprivileged** paths count for Medium+.
5. **Primacy of Rules can omit Medium SC rows.** Check rewards JSON impact tables, not just max bounty.
6. **Deployed-only rules** (Lido): repo tip may be ahead of mainnet — note pin vs deploy.

## Intake checklist

- [ ] Pull/program page: max bounty, KYC, PoC, primacy, invite-only
- [ ] Enumerate **in-scope assets** (GH paths, addresses, “all files under dir”)
- [ ] Clone **only** in-scope trees; record commit pin in SCOPE.md
- [ ] Ingest **known issues** into a kill table (id + one-liner)
- [ ] Write **trusted roles** table (who is OOS alone)
- [ ] Write **unprivileged actors** (NFT owner, shareholder, liquidator, etc.)
- [ ] Note custom OOS (weird tokens, centralization, already exploited)
- [ ] PoC validity rules (e.g. Strata ≥10/10 tranche seed; ONE_ASSET floor invalid)

## Scope freeze template (minimal)

```markdown
| Asset | Local path | Pin |
| Trusted | ... |
| Unprivileged | ... |
| Known issues | id — summary |
| This wave focus | slice description |
| Explicitly OOS | monorepo paths not listed |
```

## Kill criteria (before candidate)

| Kill if | Example |
|---------|---------|
| Root cause only in OOS asset | Pure Accounting bug when Accounting not listed |
| Requires trusted role alone | Servicer freeform ledger drain of **own** loan |
| Exact match known issue | SSV 1301 deposit grief |
| Design-ack in SECURITY.md / docs | Tare pending-offer NAV ops hazard |
| Unreachable under floor math | Fluid liquidate mul/div branch |

## See also

- Continuous board patterns in security-research `programs/_continuous-board.md`
- Candidate workflow: theoretical OK → promote / needs-info / kill
