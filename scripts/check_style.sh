#!/bin/bash

tmp_dir=$(mktemp -d)
echo "Using temp directory $tmp_dir"

# Create new console project
dotnet new console -o "$tmp_dir/tempProject" --no-restore

# Copy recursively all .cs files with folder structure
find "$path" -name '*.cs' -exec cp --parents {} "$tmp_dir/tempProject" \;

# Create solution and add project
dotnet new sln -o "$tmp_dir" -n tempCheckStyle
dotnet sln "$tmp_dir/tempCheckStyle.sln" add "$tmp_dir/tempProject/tempProject.csproj"

# Run dotnet format in check mode with severity
dotnet format "$tmp_dir/tempCheckStyle.sln" --check --fix-style "$check_severity"