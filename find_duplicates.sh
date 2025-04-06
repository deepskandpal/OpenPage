#!/bin/bash

# This script identifies duplicate Swift files between root directories 
# and the writing_app directory structure to help with restructuring

# Create log directory
mkdir -p logs

# Find all Swift files and log them
echo "Finding all Swift files..."
find . -name "*.swift" | sort > logs/all_swift_files.txt

# Find root level Swift files
echo "Finding root level Swift files..."
find Models Views ViewModels Services -name "*.swift" | sort > logs/root_swift_files.txt

# Find writing_app Swift files
echo "Finding writing_app Swift files..."
find writing_app -name "*.swift" | sort > logs/writing_app_swift_files.txt

# Function to get base filename
basename_no_ext() {
  filename=$(basename "$1")
  echo "${filename%.*}"
}

# Compare files with the same name
echo "Comparing files with the same name..."
> logs/duplicate_files.txt
> logs/unique_files.txt

# Process root files
while IFS= read -r root_file; do
  base_name=$(basename_no_ext "$root_file")
  found=0
  
  # Look for files with the same name in writing_app
  while IFS= read -r app_file; do
    app_base_name=$(basename_no_ext "$app_file")
    
    if [ "$base_name" = "$app_base_name" ]; then
      # Compare content
      if cmp -s "$root_file" "$app_file"; then
        echo "DUPLICATE: $root_file = $app_file (Same Content)" >> logs/duplicate_files.txt
      else
        echo "CONTENT DIFFERS: $root_file ≠ $app_file" >> logs/duplicate_files.txt
      fi
      found=1
      break
    fi
  done < logs/writing_app_swift_files.txt
  
  if [ $found -eq 0 ]; then
    echo "UNIQUE: $root_file" >> logs/unique_files.txt
  fi
done < logs/root_swift_files.txt

# Summary
echo "==== DUPLICATION SUMMARY ===="
echo "Total Swift files: $(wc -l < logs/all_swift_files.txt)"
echo "Root Swift files: $(wc -l < logs/root_swift_files.txt)"
echo "writing_app Swift files: $(wc -l < logs/writing_app_swift_files.txt)"
echo "Duplicate files found: $(grep -c "DUPLICATE" logs/duplicate_files.txt)"
echo "Files with content differences: $(grep -c "CONTENT DIFFERS" logs/duplicate_files.txt)"
echo "Unique root files to copy: $(wc -l < logs/unique_files.txt)"
echo "============================"

echo "Logs stored in logs/ directory"
echo "Use logs/unique_files.txt to identify files that need to be copied to OpenPage/" 