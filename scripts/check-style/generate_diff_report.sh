#!/bin/bash

INPUT_DIFF_FOLDER="$1"
INPUT_DIFF_COMMIT_SHA="$2"

Blue='\033[0;34m'
Reset='\033[0m'

# Script must receive a commit SHA as argument
printf "${Blue}Commit sha: $INPUT_DIFF_COMMIT_SHA${Reset}\n"

# Step 1: Generate the raw git diff
# Ignoring whitespace changes and showing only C# files
printf "${Blue}Generating diff...${Reset}\n"
git diff "$INPUT_DIFF_COMMIT_SHA" --ignore-space-at-eol --ignore-all-space --ignore-blank-lines --unified=0 -- "*.cs" > "$INPUT_DIFF_FOLDER/diff.patch"


# Step 2: Parse diff to generate a CSV-like output
# Format: filename,line_number for each added line
printf "${Blue}Generating line numbers report...${Reset}"
awk '
# Initialize variables for tracking current file and line positions
BEGIN { 
    current_file = ""
    start_line = 0
    line_count = 0 
}

# Extract the changed file name from diff header
/^diff --git/ {
    n = split($0, parts, " ")
    file_path = parts[n]          # This is usually the "b/<filename>"
    sub(/^b\//, "", file_path)    # Remove leading "b/"
    current_file = file_path
}

# Parse the @@ header to get line numbers
/^@@/ {
    # Extract after the plus sign
    plus_pos = index($0, "+")
    comma_pos = index(substr($0, plus_pos), ",")
    if (plus_pos > 0 && comma_pos > 0) {
        start_line = substr($0, plus_pos+1, comma_pos-1)
        line_count = 0
    }
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

printf "${Blue}Report generated at $INPUT_DIFF_FOLDER/lines.patch${Reset}\n"