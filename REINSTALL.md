OpenCode reinstall (quick)
-------------------------

If you need to reproduce the global OpenCode installation on a new machine or after a fresh clone, follow these steps:

1) Initialize submodules

   git submodule update --init --recursive

2) Generate any missing OpenCode artifacts

   ./scripts/generate-opencode.sh

   - This creates minimal `.opencode/` content for plugins that don't already provide it.
   - It is safe to re-run.

3) Install to your global OpenCode config

   ./install-opencode.sh

Notes
- If a plugin contains TypeScript translators (`plugins/*/build/translate.ts`) you can run them to produce richer agent metadata before step 2. Example:

  cd plugins/backlog && bun run build/translate.ts

- If `bun` is not available you can use `npx tsx` instead:

  cd plugins/backlog && npx tsx build/translate.ts

That's it — after step 3 your `~/.config/opencode` will contain the installed commands, agents, and skills.
