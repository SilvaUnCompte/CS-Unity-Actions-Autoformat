#!/bin/bash

tmp_dir=$(mktemp -d)
echo "Using temp directory $tmp_dir"

# Create new console project
dotnet new console -o "$tmp_dir/tempProject" --no-restore

# Copy all .cs files recursively preserving folders
find "$path" -name '*.cs' -exec cp --parents {} "$tmp_dir/tempProject" \;

# Modify csproj to include all .cs files recursively
csproj="$tmp_dir/tempProject/tempProject.csproj"
sed -i '/<\/Project>/ i\
  <ItemGroup>\
    <Compile Include="**\*.cs" />\
  </ItemGroup>' "$csproj"

# Create solution with explicit name
dotnet new sln -o "$tmp_dir" -n tempCheckStyle

# Add project to the solution
dotnet sln "$tmp_dir/tempCheckStyle.sln" add "$csproj"

# Restore dependencies (optional but recommended)
dotnet restore "$tmp_dir/tempCheckStyle.sln"

dotnet msbuild -nologo -t:GenerateCompileDependencyCache -v:q | grep Compile # delete me !!!!!!!!!!!!!!!!!!!!!!

# Run dotnet format in check mode with severity
dotnet format "$tmp_dir/tempCheckStyle.sln" --check --fix-style "$check_severity"
