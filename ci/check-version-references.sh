#!/bin/bash

# Script to check if .tf files reference previous versions of the module
# This script should be run from the root of the repository

set -e

echo "🔍 Checking for outdated version references in .tf files..."

# Get the 10 latest semver tags (latest + 9 previous)
tags=($(git tag --list | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n 10))

# Check if we have any tags
if [ ${#tags[@]} -eq 0 ]; then
    echo "✅ No semver tags found, skipping version check."
    exit 0
fi

# If we have fewer than 2 tags, no previous versions to check
if [ ${#tags[@]} -lt 2 ]; then
    echo "✅ Only one or no tags found, no previous versions to check."
    exit 0
fi

# Remove the last one (which is the latest) and keep the previous ones
prev_tags=("${tags[@]:0:${#tags[@]}-1}")

echo "📋 Latest tag: ${tags[-1]}"
echo "📋 Previous tags to check: ${prev_tags[*]}"

# Flag to track if any outdated references are found
found_outdated=false

# Check each previous tag in all .tf files
for tag in "${prev_tags[@]}"; do
    echo "🔎 Checking for references to $tag..."
    
    # Use find to search for .tf files, then grep for the tag
    # Using -r for recursive, -n for line numbers, --include for .tf files only
    if find . -name "*.tf" -type f -exec grep -l "$tag" {} \; | grep -q "."; then
        echo "❌ Tag $tag is referenced in .tf files:"
        find . -name "*.tf" -type f -exec grep -Hn "$tag" {} \;
        found_outdated=true
    else
        echo "✅ Tag $tag is NOT referenced."
    fi
done

if [ "$found_outdated" = true ]; then
    echo ""
    echo "❌ FAIL: Found references to previous versions in .tf files!"
    echo "🔧 Please update these references to use the latest version: ${tags[-1]}"
    exit 1
else
    echo ""
    echo "✅ SUCCESS: No outdated version references found in .tf files."
    exit 0
fi 