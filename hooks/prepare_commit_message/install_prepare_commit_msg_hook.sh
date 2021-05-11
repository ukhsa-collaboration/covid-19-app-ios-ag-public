#!/bin/sh

# Copy prepare-commit-msg Git Hook into 'ROOT_PROJ_DIR/.git/hooks' directory.

GIT_HOOK=prepare-commit-msg
HOOKS_DIR=../../.git/hooks/

mkdir -p "$HOOKS_DIR"
cp "$GIT_HOOK" "$HOOKS_DIR"
cd "$HOOKS_DIR"
chmod +x "$GIT_HOOK"
