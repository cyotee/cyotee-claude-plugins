# TODO

## Consolidate backlog and design plugins to eliminate cross-plugin deps.sh dependency

The `/design` plugin currently depends on the `/backlog` plugin's `scripts/deps.sh` for dependency graph validation (cycle detection, dependency existence checks). This cross-plugin reference is fragile because the plugin cache uses versioned directories, requiring dynamic path resolution at runtime (see design v4.0.1 fix).

### Options

1. **Merge design into backlog** - The design plugin's task creation workflow is tightly coupled to the backlog plugin's task format, INDEX.md schema, and dependency system. Merging them into a single plugin eliminates the cross-plugin dependency entirely.

2. **Extract deps.sh into a shared utility plugin** - Create a small `task-utils` plugin that both backlog and design depend on. This is cleaner if other plugins also need dependency resolution.

3. **Inline a minimal deps.sh copy into design** - Copy only the functions design actually uses (`deps_build_graph`, `deps_validate`, `deps_check_cycles`) into the design plugin. Simple but creates maintenance burden with two copies.

### Recommendation

Option 1 (merge) is likely best. The design plugin exists solely to create tasks that the backlog plugin manages - they share the same INDEX.md format, task directory structure, and dependency model. A single plugin with both `/backlog` and `/design` commands would be simpler to maintain and install.
