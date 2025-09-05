#!/bin/sh -l

# ========= Setup colours =========
Reset='\033[0m'         # Text Reset
Red='\033[0;31m'        # Red
Green='\033[0;32m'      # Green
Yellow='\033[0;33m'     # Yellow

# ========= Setup variables =========
path="$INPUT_PATH"
check_only="$INPUT_CHECK_ONLY"
check_severity="$INPUT_CHECK_SEVERITY"
squash_commit="$INPUT_SQUASH_COMMIT"


# ========= Determine which commit to diff against =========
event_name="$GITHUB_EVENT_NAME"
diff_commit_sha=""

echo "Event type: $event_name"

if [ "$GITHUB_EVENT_NAME" = "pull_request" ]; then
    echo "Pull Request detected"
    if [ -n "$GITHUB_EVENT_PULL_REQUEST_BASE_SHA" ]; then
        diff_commit_sha="$GITHUB_EVENT_PULL_REQUEST_BASE_SHA"
    else
        echo "No PR base SHA found, falling back to HEAD^"
        diff_commit_sha=$(git rev-parse HEAD^)
    fi
else
    echo "Push event detected"
    if git rev-parse HEAD^ >/dev/null 2>&1; then
        diff_commit_sha=$(git rev-parse HEAD^)
        echo "Using previous commit: $diff_commit_sha"
    else
        echo "No previous commit found (possibly first commit), using empty tree"
        diff_commit_sha=$(git hash-object -t tree /dev/null)
    fi
fi


# ========= Force check_severity to 'warn' or 'error', otherwise default to 'error' =========
if [ "$check_severity" != "warn" ] && [ "$check_severity" != "error" ]; then
    check_severity="error"
fi

echo "\n"
echo "Path: $path"
echo "Check only: $check_only"
echo "Check severity: $check_severity"
echo "Squash commit: $squash_commit"
echo "Base commit: $diff_commit_sha"

# ========= Get GitHub branch information =========
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
    echo "${Green}$path exists!${Reset}"

    if [ "$check_only" = "true" ]; then
        echo "${Yellow}Check-only mode enabled${Reset}"
        . /check_style.sh
    else
        echo "${Yellow}Auto-formatting enabled${Reset}"
        . /auto_format.sh
    fi
    
    printf "\n"
else
    echo "${Red}$path does not exist${Reset}"
fi
