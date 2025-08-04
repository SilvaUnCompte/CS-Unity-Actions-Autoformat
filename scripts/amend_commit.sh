#!/bin/bash

TMP_FILE=$(mktemp)

git log -1 --pretty=%B > "$TMP_FILE"

TITLE=$(head -n1 "$TMP_FILE")
BODY=$(tail -n +2 "$TMP_FILE" | sed '/./,$!d')  # Clean up empty lines at the start

if [ -z "$BODY" ]; then
    NEW_BODY="+ Auto formatted by Github Action"
else
    NEW_BODY="$BODY\n+ Auto formatted by Github Action"
fi

{
    echo "$TITLE"
    echo
    echo "$NEW_BODY"
} > "$TMP_FILE"


if ! git rev-parse HEAD~1 >/dev/null 2>&1; then
  echo "${Red}ERROR: Parent commit HEAD~1 is not accessible.${Reset}"
  echo "${Red}Please ensure the repository is cloned with enough history (e.g. 'actions/checkout@v4' with 'fetch-depth: 0' or 'fetch-depth: 2').${Reset}"
  exit 1
else
  git commit --amend -F "$TMP_FILE"
fi

rm "$TMP_FILE"
