.PHONY: generate-codex check-codex

# Dual-ship Codex artifacts from Claude marketplace SoT
generate-codex:
	python3 scripts/generate-codex-marketplace.py

check-codex:
	python3 scripts/generate-codex-marketplace.py --check
