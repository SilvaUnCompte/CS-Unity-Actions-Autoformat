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
dotnet format "tempCheckStyle.sln" --check --fix-style "$check_severity" --include "$path" -v diag > "$OUTPUT_FILE" 2>&1
exit_code=$?

# Show the output without compilation errors
echo "${Yellow}Report:${Reset}"
grep -v "error CS" "$OUTPUT_FILE"

if [ "$exit_code" -eq 2 ]; then
  echo "${Red} Format check failed: some files do not respect formatting rules.${Reset}"
  exit 1
elif [ "$exit_code" -ne 0 ]; then
  echo "${Red} dotnet format failed with unexpected error (code $exit_code)${Reset}"
  exit "$exit_code"
else
  echo "${Green}All files are correctly formatted.${Reset}"
fi