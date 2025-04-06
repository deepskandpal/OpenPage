#!/bin/bash

# This script consolidates all unique files into the OpenPage directory structure
# Run find_duplicates.sh first to generate the logs/unique_files.txt file

# Check if the unique_files.txt exists
if [ ! -f logs/unique_files.txt ]; then
  echo "Error: logs/unique_files.txt not found. Run find_duplicates.sh first."
  exit 1
fi

# Create OpenPage directory structure
echo "Creating OpenPage directory structure..."
mkdir -p OpenPage/Models OpenPage/Views OpenPage/ViewModels OpenPage/Services OpenPage/Services/AI

# Process unique files
echo "Copying unique files to OpenPage..."
while IFS= read -r file_line; do
  # Extract actual file path (strip "UNIQUE: " prefix)
  file=$(echo "$file_line" | sed 's/^UNIQUE: //')
  
  # Extract directory structure
  dir_path=$(dirname "$file")
  base_name=$(basename "$file")
  
  # Create corresponding directory in OpenPage
  target_dir="OpenPage/$dir_path"
  mkdir -p "$target_dir"
  
  # Copy file
  echo "Copying $file to $target_dir/$base_name"
  cp "$file" "$target_dir/"
done < logs/unique_files.txt

# Copy key files from root
echo "Copying main app files..."
cp writing_appApp.swift OpenPage/OpenPageApp.swift 2>/dev/null || echo "writing_appApp.swift not found"
cp writing_app.entitlements OpenPage/OpenPage.entitlements 2>/dev/null || echo "writing_app.entitlements not found"
cp ContentView.swift OpenPage/ 2>/dev/null || echo "ContentView.swift not found"
cp Item.swift OpenPage/ 2>/dev/null || echo "Item.swift not found"

# Copy all files from writing_app directories
echo "Copying writing_app directory contents..."
for dir in Models Views ViewModels Services; do
  if [ -d "writing_app/$dir" ]; then
    echo "Copying writing_app/$dir to OpenPage/$dir"
    cp -R writing_app/$dir/* OpenPage/$dir/ 2>/dev/null || true
  fi
done

# Copy Preview Content if it exists
if [ -d "writing_app/Preview Content" ]; then
  echo "Copying Preview Content..."
  cp -R "writing_app/Preview Content" OpenPage/
fi

# Copy writing_app Swift files in root
if ls writing_app/*.swift >/dev/null 2>&1; then
  echo "Copying Swift files from writing_app root..."
  cp writing_app/*.swift OpenPage/ 2>/dev/null || true
fi

echo "File consolidation complete."
echo "Next steps:"
echo "1. Create a new Xcode project named OpenPage"
echo "2. Add all files from the OpenPage directory to the project"
echo "3. Configure project settings"
echo "4. Build and test the project"
echo "5. Run the cleanup script after successful verification" 