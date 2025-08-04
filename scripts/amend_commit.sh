#!/bin/bash

TMP_FILE=$(mktemp)

git log -1 --pretty=%B > "$TMP_FILE"

TITLE=$(head -n1 "$TMP_FILE")
BODY=$(tail -n +2 "$TMP_FILE" | sed '/./,$!d')  # Clean up empty lines at the start

if [ -z "$BODY" ]; then
    NEW_BODY="+ Auto formatted by Actions"
else
    NEW_BODY="$BODY\n+ Auto formatted by Actions"
fi

{
    echo "$TITLE"
    echo
    echo -e "$NEW_BODY"
} > "$TMP_FILE"

git reset HEAD~1
git add -A
git commit -F "$TMP_FILE"

rm "$TMP_FILE"
