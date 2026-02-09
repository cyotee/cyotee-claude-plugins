#!/usr/bin/env bash
set -euo pipefail

# generate-opencode.sh
# Create minimal .opencode/ artifacts for plugins that lack them.
# This attempts to preserve as much as possible: commands, agents, skills.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGINS_DIR="$ROOT_DIR/plugins"

log() { printf "[generate] %s\n" "$1"; }

for plugin in "$PLUGINS_DIR"/*; do
  [[ -d "$plugin" ]] || continue
  name=$(basename "$plugin")
  opencode_dir="$plugin/.opencode"
  if [[ -d "$opencode_dir" ]]; then
    log "$name: .opencode exists — skipping"
    continue
  fi

  has_any=false
  mkdir -p "$opencode_dir"

  # Commands
  if compgen -G "$plugin/commands/*.md" >/dev/null 2>&1; then
    mkdir -p "$opencode_dir/commands"
    for cmd in "$plugin"/commands/*.md; do
      [[ -f "$cmd" ]] || continue
      base=$(basename "$cmd")
      out="$opencode_dir/commands/$base"

      # extract description and body (after second ---) using perl for portability
      description=$(perl -0777 -ne 'if (m/^---\s*\n(.*?)\n---/s) { if ($1 =~ /^description:\s*(.*)$/m) { print $1 } }' "$cmd" || true)
      if [[ -z "$description" ]]; then
        # fallback: take first non-empty line of file
        description=$(awk 'NF{print; exit}' "$cmd" | sed 's/\#/ /g' || true)
      fi
      printf "---\ndescription: %s\n---\n\n" "$description" > "$out"
      perl -0777 -ne 'if (m/^---\s*\n(?:.*?\n)---\s*\n(.*)/s) { print $1 }' "$cmd" >> "$out" || true
      has_any=true
      log "$name: created command $base"
    done
  fi

  # Agents
  if compgen -G "$plugin/agents/*.md" >/dev/null 2>&1; then
    mkdir -p "$opencode_dir/agents"
    for ag in "$plugin"/agents/*.md; do
      [[ -f "$ag" ]] || continue
      base=$(basename "$ag")
      out="$opencode_dir/agents/$base"

      description=$(perl -0777 -ne 'if (m/^---\s*\n(.*?)\n---/s) { if ($1 =~ /^description:\s*(.*)$/m) { print $1 } }' "$ag" || true)
      model=$(perl -0777 -ne 'if (m/^---\s*\n(.*?)\n---/s) { if ($1 =~ /^model:\s*(.*)$/m) { print $1 } }' "$ag" || true)

      # model map
      case "$model" in
        sonnet) oc_model="anthropic/claude-sonnet" ;;
        haiku) oc_model="anthropic/claude-haiku" ;;
        opus) oc_model="anthropic/claude-opus" ;;
        *) oc_model="anthropic/claude-sonnet" ;;
      esac

      printf "---\ndescription: %s\nmode: subagent\nmodel: %s\ntools:\n  read: true\n  glob: true\n  grep: true\n  bash: true\n  write: false\n  edit: false\n---\n\n" "$description" "$oc_model" > "$out"
      perl -0777 -ne 'if (m/^---\s*\n(?:.*?\n)---\s*\n(.*)/s) { print $1 }' "$ag" >> "$out" || true
      has_any=true
      log "$name: created agent $base"
    done
  fi

  # Skills - copy existing skills dir to .opencode/skills
  if [[ -d "$plugin/skills" ]]; then
    mkdir -p "$opencode_dir/skills"
    for s in "$plugin"/skills/*/; do
      [[ -d "$s" ]] || continue
      skill_name=$(basename "$s")
      mkdir -p "$opencode_dir/skills/$skill_name"
      cp -r "$s"* "$opencode_dir/skills/$skill_name/" 2>/dev/null || true
      has_any=true
      log "$name: copied skill $skill_name"
    done
  fi

  if [[ "$has_any" = false ]]; then
    # no content generated; remove created directory
    rmdir "$opencode_dir" 2>/dev/null || true
    log "$name: no commands/agents/skills found — nothing generated"
  else
    log "$name: .opencode generated"
  fi
done

log "Done"
