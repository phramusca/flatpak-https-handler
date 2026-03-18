#!/usr/bin/env bash
set -euo pipefail

# This script runs on the devcontainer "host" side (WSL) before the container starts.
# Goal: expose the *existing* SSH agent socket to the container without ever copying keys.
#
# We create a stable symlink inside the workspace, then bind-mount it into the container.

# Stable mount source path for Docker (in /tmp to avoid polluting the repo).
SOCK_LINK="/tmp/flatpak-https-handler-ssh-agent.sock"

rm -f "$SOCK_LINK"

# If SSH_AUTH_SOCK is already set and valid, use it.
if [ -n "${SSH_AUTH_SOCK:-}" ] && [ -S "$SSH_AUTH_SOCK" ]; then
  AGENT_SOCK="$SSH_AUTH_SOCK"
else
  # Fallback: Cursor/Dev Containers may not propagate SSH_AUTH_SOCK into the
  # environment where initializeCommand runs. In that case, try to locate
  # an already-running agent socket under /tmp.
  AGENT_SOCK=""
  for candidate in /tmp/ssh-*/agent.*; do
    [ -S "$candidate" ] || continue
    # Quick health check: does ssh-add talk to this socket?
    if SSH_AUTH_SOCK="$candidate" ssh-add -l >/dev/null 2>&1; then
      AGENT_SOCK="$candidate"
      break
    fi
  done
fi

if [ -z "${AGENT_SOCK:-}" ]; then
  # No reachable agent: start one on our fixed socket.
  # If your key is passphrase-protected, this may fail in non-interactive mode;
  # in that case, you'll need to run `ssh-add` once manually in WSL.
  eval "$(ssh-agent -a "$SOCK_LINK" -s)" >/dev/null

  KEY_PATH=""
  if [ -f "$HOME/.ssh/id_ed25519" ]; then
    KEY_PATH="$HOME/.ssh/id_ed25519"
  elif [ -f "$HOME/.ssh/id_rsa" ]; then
    KEY_PATH="$HOME/.ssh/id_rsa"
  fi

  if [ -z "$KEY_PATH" ]; then
    echo "Error: no SSH key found at ~/.ssh/id_ed25519 or ~/.ssh/id_rsa." >&2
    exit 1
  fi

  if ! ssh-add "$KEY_PATH" </dev/null 2>/dev/null; then
    echo "Error: ssh-agent started, but couldn't load your key non-interactively." >&2
    echo "Run 'ssh-add ~/.ssh/id_ed25519' in WSL (once) to load the key, then restart Cursor/devcontainer." >&2
    exit 1
  fi
else
  # Reuse existing agent socket.
  ln -sf "$AGENT_SOCK" "$SOCK_LINK"
fi

