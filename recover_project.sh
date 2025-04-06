#!/bin/bash

# This script helps recover and verify files from the backup
# It also assists in creating a new Xcode project structure

# Set backup directory
BACKUP_DIR="backup_20250406_143818"

# Check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
  echo "Error: Backup directory $BACKUP_DIR not found."
  exit 1
fi

# Function to check what's in the backup
check_backup() {
  echo "===== Backup Directory Contents ====="
  find "$BACKUP_DIR" -type f | grep -v ".DS_Store" | sort
  echo ""
  
  # Check if Xcode project exists in backup
  if [ -d "$BACKUP_DIR/writing_app.xcodeproj" ]; then
    echo "✅ Found writing_app.xcodeproj in backup."
    echo "Structure of writing_app.xcodeproj:"
    find "$BACKUP_DIR/writing_app.xcodeproj" -type f | sort
  else
    echo "❌ writing_app.xcodeproj not found in backup."
  fi
}

# Function to recover Xcode project structure
recover_project_structure() {
  echo "===== Recovering Project Structure ====="
  
  # Create empty OpenPage.xcodeproj directory structure based on the backup structure
  if [ -d "$BACKUP_DIR/writing_app.xcodeproj" ]; then
    echo "Creating OpenPage.xcodeproj directory structure..."
    mkdir -p OpenPage.xcodeproj
    
    # List directories to create
    backup_dirs=$(find "$BACKUP_DIR/writing_app.xcodeproj" -type d | sed "s|$BACKUP_DIR/writing_app.xcodeproj|OpenPage.xcodeproj|g")
    
    # Create directory structure
    for dir in $backup_dirs; do
      if [ "$dir" != "OpenPage.xcodeproj" ]; then
        mkdir -p "$dir"
        echo "Created directory: $dir"
      fi
    done
    
    echo "✅ Created OpenPage.xcodeproj directory structure"
    echo ""
    echo "NOTE: This only creates an empty structure. You still need to:"
    echo "1. Create a new Xcode project named 'OpenPage'"
    echo "2. Add existing files from the OpenPage directory"
    echo "3. Configure project settings (bundle identifier, entitlements, etc.)"
  else
    echo "❌ Cannot recover structure: writing_app.xcodeproj not found in backup."
  fi
}

# Main menu
echo "OpenPage Project Recovery Tool"
echo "============================="
echo "This tool helps you recover from the project restructuring and verify backup files."
echo ""
echo "Select an option:"
echo "1. Check what's in the backup"
echo "2. Recover project structure"
echo "3. Exit"
echo ""
read -p "Enter option (1-3): " option

case $option in
  1)
    check_backup
    ;;
  2)
    recover_project_structure
    ;;
  3)
    echo "Exiting..."
    exit 0
    ;;
  *)
    echo "Invalid option. Exiting..."
    exit 1
    ;;
esac

echo ""
echo "Done." 