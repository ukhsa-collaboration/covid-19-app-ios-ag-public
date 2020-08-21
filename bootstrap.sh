#!/bin/sh

# copy pre-comit to ./git/hooks
mkdir -p .git/hooks
cp hooks/pre-commit .git/hooks/pre-commit

# copy snippets to ~/Library/Developer/Xcode/UserData/CodeSnippets
mkdir -p ~/Library/Developer/Xcode/UserData/CodeSnippets
cp -i Snippets/* ~/Library/Developer/Xcode/UserData/CodeSnippets
