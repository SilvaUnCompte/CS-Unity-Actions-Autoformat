#!/bin/bash

PROJECT_NAME="tempCheckStyle"
OUTPUT_FILE=$(mktemp)
DIFF_FOLDER=$(mktemp -d)

# Create new console project
dotnet new console --no-restore --force

# Modify csproj to include all .cs files recursively
csproj=$(find "./" -maxdepth 1 -name "*.csproj" | head -n 1)

if [ -z "$csproj" ]; then
  echo "${Red}No .csproj file found. "dotnet new" probably failed.${Reset}"
  exit 1
fi
echo "${Green}Project file found: $csproj${Reset}"

# Create solution
dotnet new sln -n "$PROJECT_NAME"

# Add project to the solution
dotnet sln "$PROJECT_NAME.sln" add "$csproj"

# Restore dependencies (optional but recommended)
dotnet restore "$PROJECT_NAME.sln"

# Run dotnet format in check mode with severity
dotnet format "tempCheckStyle.sln" --check --fix-style "$check_severity" --include "$path" -v diag > "$OUTPUT_FILE" 2>&1
cat "$OUTPUT_FILE"

echo "${Yellow}==================== BEGIN CHECK STYLE ====================${Reset}"

# Filter the output for warnings and errors
filtered_output=$(grep -E "warning|error" "$OUTPUT_FILE" | grep -vE "CS[0-9]{4}" || true)
filtered_build_output=$(grep -E "warning CS[0-9]{4}" "$OUTPUT_FILE" || true)

# Remove lines related to "Program.cs"
filtered_output=$(echo "$filtered_output" | grep -v "Program.cs" || true)
filtered_build_output=$(echo "$filtered_build_output" | grep -v "Program.cs" || true)

# Apply diff check if enabled
if [ "$diff_check" = "true" ]; then
    echo "${Yellow}Diff check enabled, filtering results based on changes since $diff_commit_sha${Reset}"

    # Generate the diff report
    bash "/check-style/generate_diff_report.sh" "$DIFF_FOLDER" "$diff_commit_sha"
    
    # Filter the output based on the diff report
    filtered_output=$(echo "$filtered_output" | bash "/check-style/check_in_diff_report.sh" "$DIFF_FOLDER/lines.patch")
    filtered_build_output=$(echo "$filtered_build_output" | bash "/check-style/check_in_diff_report.sh" "$DIFF_FOLDER/lines.patch")
fi

# Display the filtered output
echo "$filtered_output"
echo "$filtered_build_output"

# Count the number of lines in the filtered output
line_count=$(echo "$filtered_output" | grep -cve '^\s*$')
line_count_build=$(echo "$filtered_build_output" | grep -cve '^\s*$')

echo "${Yellow}==================== END CHECK STYLE ====================${Reset}"

# Build output handling
# Result handling
if [ $line_count_build -gt 0 ]; then
    echo "${Red}Build warnings found $line_count_build issues.${Reset}"
else
    echo "${Green}No build issues found.${Reset}"
fi

# Result handling
if [ $line_count -gt 0 ]; then
    echo "${Red}Check style found $line_count issues.${Reset}"
else
    echo "${Green}No check style issues found.${Reset}"
fi

if [ $line_count -gt 0 ] || [ $line_count_build -gt 0 ]; then
    echo "${Red}Exiting with errors.${Reset}"
    exit 1
else
    echo "${Green}No issues found, exiting successfully.${Reset}"
    exit 0
fi