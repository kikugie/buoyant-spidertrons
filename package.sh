#!/bin/bash
# Packages the mod into '$name_$version.zip'

if [ ! -f "info.json" ]; then
  echo "info.json not found in the current directory."
  exit 1
fi

name=$(jq -r '.name' info.json)
version=$(jq -r '.version' info.json)
if [ -z "$name" ] || [ -z "$version" ]; then
  echo "Name or version field is missing in info.json."
  exit 1
fi

archive_name="${name}_${version}.zip"
folder_name="${name}_${version}"
temp_dir=$(mktemp -d)
mkdir "$temp_dir/$folder_name"

# Excluded files and directories
excluded=(
  "$(basename "$0")"
  "."
  ".git"
  ".run"
  ".idea"
  ".github"
  "releases"
  "node_modules"
)

# Construct the find command with exclude patterns
find_command="find . -maxdepth 1"
for pattern in "${excluded[@]}"; do
  find_command+=" ! -name '$pattern'"
done
find_command+=" -exec cp -r {} \"$temp_dir/$folder_name/\" \;"

# Execute the find command
eval "$find_command"

(cd "$temp_dir" && zip -r "$archive_name" "$folder_name")

# Default output directory is the current directory
output_dir="releases"
# If an argument is provided, use it as the output directory
if [ "$#" -ge 1 ]; then
  output_dir="$1"
  # Create the directory if it doesn't exist
  mkdir -p "$output_dir"
fi

mv "$temp_dir/$archive_name" "$output_dir"
rm -rf "$temp_dir"

echo "Files zipped into ${output_dir}/${archive_name}"