#!/bin/sh -l

# Setup colours
Reset='\033[0m'         # Text Reset
Red='\033[0;31m'        # Red
Green='\033[0;32m'      # Green
Yellow='\033[0;33m'     # Yellow

# Setup variables
path="$INPUT_PATH"
check_only="$INPUT_CHECK_ONLY"
squash_commit="$INPUT_SQUASH_COMMIT"

echo "Path: $path"
echo "Check only: $check_only"
echo "Squash commit: $squash_commit"

# Get GitHub branch information
BRANCH=$(echo "$GITHUB_REF" | sed 's|refs/heads/||')


# Install dotnet
dotnet tool install -g dotnet-format

# Set the path to the tool
export PATH="$PATH:/github/home/.dotnet/tools"


# Clean up the console
printf "\n"
printf "\n${Yellow}==================== BEGIN FORMATTING ====================${Reset}"
printf "\n"
printf "\n"


# Confirm existence of folder
if [ -d "$path" ]; then

    # Announce that the path exists
    echo "${Green}$path exists!${Reset}"

    if [ "$check_only" = "true" ]; then
        echo "${Yellow}Check-only mode enabled${Reset}"

        # Check files in folder
        dotnet format -f -w "$path" --verify-no-changes --severity error
    else
        echo "${Yellow}Auto-formatting enabled${Reset}"

        # Format files in folder
        dotnet format -f -w "$path"

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
            git add -A

            if [ "$squash_commit" = "true" ]; then
                # Squash commit
                echo "${Yellow}Squash committing changes${Reset}"
                . /amend_commit.sh
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
    fi
    printf "\n${Yellow}==================== END FORMATTING ====================${Reset}"
    printf "\n"
else
    echo "${Red}$path does not exist${Reset}"
fi
