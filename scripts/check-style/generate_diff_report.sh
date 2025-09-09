#!/bin/bash

INPUT_COMMIT_SHA="$1"
INPUT_DIFF_FOLDER="$2"

# Script must receive a commit SHA as argument
echo "${Blue}Commit sha: $INPUT_COMMIT_SHA${Reset}"


# Step 1: Generate the raw git diff
# Ignoring whitespace changes and showing only C# files
echo "${Blue}Generating diff...${Reset}"
git diff $INPUT_COMMIT_SHA --ignore-space-at-eol --ignore-all-space --ignore-blank-lines --unified=0 -- "*.cs" > "$INPUT_DIFF_FOLDER/diff.patch"


# Step 2: Parse diff to generate a CSV-like output
# Format: filename,line_number for each added line
echo "${Blue}Generating line numbers report...${Reset}"
awk '
# Initialize variables for tracking current file and line positions
BEGIN { 
    current_file = ""
    start_line = 0
    line_count = 0 
}

# Extract the changed file name from diff header
/^diff --git/ {
    match($0, /b\/(.+)$/, arr)
    current_file = arr[1]
}

# Parse the @@ header to get line numbers
# Format: @@ -old_start,old_count +new_start,new_count @@
/^@@/ {
    match($0, /@@ -([0-9]+),([0-9]+) \+([0-9]+),([0-9]+)/, arr)
    start_line = arr[3]  # Use the new file line number (after +)
    line_count = 0
    next
}

# Process added lines (starting with +)
$0 ~ /^\+/ {
    # Skip diff header lines (+++), process only if we have valid context
    if ($0 !~ /^\+\+\+/ && current_file != "" && start_line != 0) {
        current_line = start_line + line_count
        print current_file "," current_line
    }
    line_count++
}
' "$INPUT_DIFF_FOLDER/diff.patch" > "$INPUT_DIFF_FOLDER/lines.patch"

echo "${Blue}Report generated at $INPUT_DIFF_FOLDER/lines.patch${Reset}"