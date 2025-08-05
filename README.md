# C# Unity Auto Formatter

This action can be used to check or auto format C# scripts like in Unity project. Works with all type of project containing .cs files.
I'm active on Github so pull requests and issues are welcome.

This action is built on top of the work of others, so a big thank you to `tyirvine/Unity-Actions-Autoformat@1.0.6`, `andstor/file-existence-action@v1.0.1`, `andstor/file-existence-action@v1.0.1`, and @shiena for the inspiration!

Here's the original gist → https://gist.github.com/shiena/197f949bc513858a85883d5529730310

## Usage

```yaml
  steps:
    - uses: actions/checkout@v4 # Checks-out your repository under $GITHUB_WORKSPACE, so your job can access it
      with:
        fetch-depth: 2  # Needed if you want to amend the last commit (e.g. for squash commits)

    # Runs a single command using the runners shell
    - name: Unity Auto Format
      uses: SilvaUnCompte/CS-Unity-Actions-Autoformat@v1.0.0 # check available version before using
      with:
        path: ./Assets/Scripts/ # Path to your scripts directory
        check_only: 'false' # Set to 'true' to only verify formatting without making changes (true|false, default: 'false')
        check_severity: 'warn' # Set to 'warn' or 'error' to specify the severity of style checks (warn|error, default: 'error')
        squash_commit: 'true' # Set to 'true' to edit the previous commit instead of creating a new one (true|false, default: 'false')
```
Check out [example-workflow.yml](example-workflow.yml) for a full example of this action in use.

## What it does
It all depends on the options:

- With the `check-only` option enabled: it takes the path, checks the style and generates an error if the style does not match requirements. Only errors related to style tags defined as "error" in `.editorconfig` are reported. Or you can set `check_severity` to "warn" if you want to be more strict and report "warning" rules of `.editorconfig`.

- With the `check-only` option set to false (default):

  - With the `squash-commit` option set to false: it takes the path, formats all scripts, validates all files in a new commit, then push them to the active branch.

  - With the `squash-commit` option enabled: it takes the path, formats all scripts, validates all files and modifies the last commit.

> *By default, `check-only` and `squash-commit` are disabled.*

If you need to apply the formatter to all files, set `path` to "./"

## Config
The formatting align its rules with the `.editorconfig` file at the root. This is a standard file. Documentation here: [https://learn.microsoft.com..](https://learn.microsoft.com/en-us/dotnet/fundamentals/code-analysis/code-style-rule-options)

Here is an example: [.editorconfig](./example-.editorconfig)
```bash
# top-most EditorConfig file
root = true

# All C# files
[*.cs]

# Indentation
indent_style = space:error
indent_size = 4:error

# Trim whitespace
trim_trailing_whitespace = true
insert_final_newline = true

# dotnet code style rules
dotnet_sort_system_directives_first = true
dotnet_separate_import_directive_groups = false

dotnet_style_qualification_for_field = false:silent
dotnet_style_qualification_for_property = false:silent
dotnet_style_qualification_for_method = false:silent
dotnet_style_qualification_for_event = false:silent

# Expression preferences
dotnet_style_prefer_is_null_check_over_reference_equality_method = true:none
dotnet_style_prefer_auto_properties = false:suggestion

# Require visibility modifiers (public/private)
dotnet_style_require_accessibility_modifiers = always:suggestion   # !!

# Prefer null propagation
dotnet_style_coalesce_expression = true:suggestion
dotnet_style_null_propagation = false:silent

# C# specific formatting
csharp_new_line_before_open_brace = all:suggestion  # !!
csharp_indent_case_contents = true:warning
csharp_indent_switch_labels = true:warning
csharp_prefer_braces = false
csharp_prefer_simple_default_expression = true:suggestion

# Use 'var' only when the type is apparent
csharp_style_var_for_built_in_types = false:warning
csharp_style_var_when_type_is_apparent = false:warning
csharp_style_var_elsewhere = false:warning

# Prefer expression-bodied members only for lambdas
csharp_style_expression_bodied_methods = true
csharp_style_expression_bodied_properties = true

# Prefer object/collection initializers
dotnet_style_object_initializer = true:suggestion
dotnet_style_collection_initializer = true:suggestion
```
