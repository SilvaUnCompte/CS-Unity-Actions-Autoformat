# Format files in folder
dotnet format -f "$path"

# Check for changes
if [ -n "$(git status --porcelain)" ]; then
    # Changes
    echo "${Green}Changes detected${Reset}"

    # Configure Git
    git config user.email "github-actions[bot]@users.noreply.github.com"
    git config user.name "github-actions[bot]"
    git remote set-url origin "https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
    git checkout "$BRANCH"

    # Commit
    git add .
    
    if [ "$squash_commit" = "true" ]; then
        # Squash commit
        echo "${Yellow}Squash committing changes${Reset}"
        . "/auto-format/amend_commit.sh"
    else
        # Regular commit
        echo "${Yellow}Committing changes${Reset}"
        git commit -m "Formatted Scripts"
    fi

    # Push
    git push --force-with-lease

    echo "${Green}Changes pushed to $BRANCH${Reset}"
else
    # No changes
    echo "${Green}No changes detected${Reset}"
fi