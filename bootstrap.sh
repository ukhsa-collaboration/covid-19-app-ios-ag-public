#!/bin/sh

# copy pre-comit to ./git/hooks
mkdir -p .git/hooks
cp hooks/pre-commit .git/hooks/pre-commit
