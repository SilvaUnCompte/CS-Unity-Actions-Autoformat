#!/bin/bash


# Read from stdin line by line
while IFS= read -r line; do
    # Extract the file path and line number from the error message
    # Format: /github/workspace/Assets/Scripts/MyFile.cs(24,15): warning CS0168 and some info
    if [[ $line =~ /github/workspace/(.+)\(([0-9]+),.*\).* ]]; then
        file_path="${BASH_REMATCH[1]}"
        line_number="${BASH_REMATCH[2]}"

        # Check if this file and line is in the diff (lines.patch)
        if grep -q "^$file_path,$line_number\$" "$DIFF_FOLDER/lines.patch"; then

            # If yes, keep this line
            echo "$line"
        fi
    fi
done