#!/bin/bash

PROJECT_NAME="tempCheckStyle"

# Create new console project
dotnet new console --no-restore

# Modify csproj to include all .cs files recursively
csproj=$(find "./" -maxdepth 1 -name "*.csproj" | head -n 1)

if [ -z "$csproj" ]; then
  echo "${Red}No .csproj file found. "dotnet new" probably failed.${Reset}"
  exit 1
fi
echo "${Green}Project file found: $csproj${Reset}"

sed -i '/<\/Project>/ i\
  <ItemGroup>\
    <Compile Include="**\\*.cs" />\
  </ItemGroup>' "$csproj"

# Create solution
dotnet new sln -n "$PROJECT_NAME"

# Add project to the solution
dotnet sln "$PROJECT_NAME.sln" add "$csproj"

# Restore dependencies (optional but recommended)
dotnet restore "$PROJECT_NAME.sln"

# Run dotnet format in check mode with severity
dotnet format "$PROJECT_NAME.sln" --check --fix-style "$check_severity" -v diag
