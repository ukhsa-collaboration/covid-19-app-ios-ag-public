#!/bin/sh

# Delete prepare-commit-msg Git Hook from 'ROOT_PROJ_DIR/.git/hooks' directory.

GIT_HOOK=../../.git/hooks/prepare-commit-msg

if [ -f "$GIT_HOOK" ]; then
  rm "$GIT_HOOK"
fi
