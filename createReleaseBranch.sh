#!/bin/bash

set -e

CONFIRMATION="This script will delete local \"release\" branch if it exists. \
Continue (y/n)? "

read -p "$CONFIRMATION" choice
if [[ ! $choice =~ ^[Yy]$ ]]; then
  echo "Script execution aborted"
  exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
  echo "Unsaved changes detected"
  echo "Please commit or stash them before running this script"
  exit 1
fi

git checkout develop
git pull origin develop

if git show-ref --quiet refs/heads/release; then
  git branch -D release
fi

git checkout -b release

npx lerna version major --force-publish --yes --no-push --message "Release: %s"

LERNA_FILE=$(git rev-parse --show-toplevel)/lerna.json
NEW_VERSION=$(awk -F\" '/"version":/ {print $4}' $LERNA_FILE)

git push origin release
git push origin v$NEW_VERSION
