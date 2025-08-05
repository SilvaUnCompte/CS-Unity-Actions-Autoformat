#!/bin/bash

PROJECT_NAME="tempCheckStyle"
OUTPUT_FILE=$(mktemp)

# Create new console project
dotnet new console --no-restore

# Modify csproj to include all .cs files recursively
csproj=$(find "./" -maxdepth 1 -name "*.csproj" | head -n 1)

if [ -z "$csproj" ]; then
  echo "${Red}No .csproj file found. "dotnet new" probably failed.${Reset}"
  exit 1
fi
echo "${Green}Project file found: $csproj${Reset}"

# sed -i "/<Project / a\
#   <PropertyGroup>\n\
#     <EnableDefaultCompileItems>false</EnableDefaultCompileItems>\n\
#   </PropertyGroup>" "$csproj"
# 
# sed -i "/<\/Project>/ i\
#   <ItemGroup>\n\
#     <Compile Include=\"$path/**/*.cs\" />\n\
#   </ItemGroup>" "$csproj"

# Create solution
dotnet new sln -n "$PROJECT_NAME"

# Add project to the solution
dotnet sln "$PROJECT_NAME.sln" add "$csproj"

# Restore dependencies (optional but recommended)
dotnet restore "$PROJECT_NAME.sln"

# Run dotnet format in check mode with severity
dotnet format "tempCheckStyle.sln" --fix-style "$check_severity" --include "$path" -v diag > "$OUTPUT_FILE" 2>&1
cat "$OUTPUT_FILE"

echo "${Yellow}==================== BEGIN CHECK STYLE ====================${Reset}"

# Filter the output for warnings and errors
filtered_output=$(grep -E "warning|error" "$OUTPUT_FILE" | grep -vE "CS[0-9]{4}" || true)
echo "$filtered_output"

# Count the number of lines in the filtered output
line_count=$(echo "$filtered_output" | grep -cve '^\s*$')

echo "${Yellow}==================== END CHECK STYLE ====================${Reset}"

# Result handling
if [ $line_count -gt 0 ]; then
    echo "${Red}Check style found $line_count issues.${Reset}"
    exit 1
else
    echo "${Green}No issues found.${Reset}"
    exit 0
fi