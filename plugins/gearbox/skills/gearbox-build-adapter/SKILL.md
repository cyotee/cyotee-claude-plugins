---
name: gearbox-build-adapter
description: >
  Build Gearbox V3 credit-account adapters and router integrations: creditFacadeOnly
  entry, force recipient to credit account, path allowlists, approve hygiene, safe
  prices, phantom tokens, post-multicall health checks. Use when implementing a
  Gearbox adapter, zapper, or bot that mutates a credit account.
---

# Build a Gearbox V3 adapter / integration

## Conceptual overview

Users hold positions in **credit accounts** (CAs). External protocols are reached only through **adapters** invoked from the **Credit Facade multicall**. Your adapter must never send tokens to an arbitrary `msg.sender` recipient — always the CA.

## Happy path (user swap on CA)

```text
1. User opens / funds credit account (pool + facade)
2. User (or frontend) submits creditFacade.multicall([
     adapter.swap(...),  // creditFacadeOnly
     ...
   ])
3. Adapter: validate path → force to = CA → approve → external call → reset approve
4. Facade: full collateral check (HF ≥ 1) unless closed/liq path allows skip
```

## Adapter skeleton (Solidity patterns)

```solidity
// Patterns — not a copy-paste production template
modifier creditFacadeOnly() {
    require(msg.sender == creditFacade, "CORE"); // or protocol equivalent
    _;
}

function swapExactIn(/* path, amountIn, minOut, ... */) external creditFacadeOnly {
    address ca = _creditAccount(); // from CM context
    // 1) Validate path length exactly (PATH_2/3/4) — no trailing padding
    // 2) _getMaskOrRevert every token that will be touched / enabled
    // 3) Overwrite any user-supplied `to` / `recipient` with `ca`
    // 4) IERC20(tokenIn).forceApprove(router, amountIn);
    // 5) router.exactInput(... recipient: ca ...);
    // 6) forceApprove(router, 1) or 0 — leave no unbounded allowance
    // 7) Do not skip facade collateral check (caller multicall handles FCC)
}
```

## Integration rules

| Rule | Detail |
|------|--------|
| **Entry** | State-changing methods `creditFacadeOnly` (or botMulticall for bots) |
| **Recipient** | Always CA; ignore external `to`/`receiver` |
| **Paths** | Exact byte lengths; exactOutput approves **last** token in reversed path |
| **Allowlist** | Configurator-set tokens; mask every asset before enable |
| **Approves** | Max → call → reset to 1 (or 0 on migrators) |
| **Safe prices** | `true` for DEX/slippage/Pendle/delayed withdraw; `false` for 1:1 wrap/stake |
| **External calldata** | Rebuild structs (e.g. Pendle TokenInput) — strip untrusted SwapData |
| **Phantoms** | `balanceOf` may reflect pending; withdraw via `IPhantomTokenWithdrawer` |
| **Gateways** | Per-user pending caps; never “drain gateway balance” |

## Bot integrations

- Partial liquidation bot perms must match exactly: e.g. `DECREASE_DEBT \| WITHDRAW_COLLATERAL`
- Bots must **not** receive `SET_BOT_PERMISSIONS`
- Always full collateral check; withdraw uses safe prices
- Soft HF band is optional UX — does not replace facade FCC
- User must approve that bot instance on the CA

## Footguns

| Footgun | Fix |
|---------|-----|
| Pass-through `recipient` | Force CA |
| Padded UniV3 path | Exact length only |
| exactOut approve first token | Approve last (output side of reversed path) |
| Leave max router allowance | Reset approve after call |
| Skip HF after swap | Never set SKIP_COLLATERAL_CHECK on normal user multicall |
| Treat pool ERC20 balance as totalAssets | Use `expectedLiquidity` / protocol accounting |

## Testing

- Unit: harness adapter + mock CM/facade; assert `to == ca` in encoded call  
- Unit: path length edges; wrong mask reverts  
- Fork: real router swap on CA; HF after; allowance ≤ 1 after  
- Bot: permission bit mismatch reverts; post-liq HF ≥ 1  

## See also

- `skill:credit-account-adapter-facade` — security review checklist  
- security-research: `programs/immunefi-gearbox/notes/patterns-for-skills.md`  
- Gearbox V3.1 scope docs in `Gearbox-protocol/security` bug-bounty folder  
