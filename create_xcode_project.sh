#!/bin/bash

# This script helps create a new Xcode project with the name "OpenPage"
# It provides a template for project.pbxproj based on the backup

# Set backup directory
BACKUP_DIR="backup_20250406_143818"

echo "OpenPage Xcode Project Setup"
echo "==========================="
echo "This script helps you create a new Xcode project for OpenPage."
echo ""

# Make sure OpenPage.xcodeproj exists
if [ ! -d "OpenPage.xcodeproj" ]; then
  echo "❌ OpenPage.xcodeproj directory not found."
  echo "Please run the recover_project.sh script first to create the directory structure."
  exit 1
fi

# Check if the original project.pbxproj exists in backup
if [ ! -f "$BACKUP_DIR/writing_app.xcodeproj/project.pbxproj" ]; then
  echo "❌ Could not find original project.pbxproj in backup."
  exit 1
fi

# Copy and prepare template project.pbxproj
echo "Copying and preparing project.pbxproj template..."
cp "$BACKUP_DIR/writing_app.xcodeproj/project.pbxproj" "OpenPage.xcodeproj/project.pbxproj.template"

# Copy contents.xcworkspacedata
if [ -f "$BACKUP_DIR/writing_app.xcodeproj/project.xcworkspace/contents.xcworkspacedata" ]; then
  echo "Copying contents.xcworkspacedata..."
  cp "$BACKUP_DIR/writing_app.xcodeproj/project.xcworkspace/contents.xcworkspacedata" "OpenPage.xcodeproj/project.xcworkspace/contents.xcworkspacedata"
  # Update the file to reference OpenPage instead of writing_app
  sed -i '' 's/writing_app.xcodeproj/OpenPage.xcodeproj/g' "OpenPage.xcodeproj/project.xcworkspace/contents.xcworkspacedata"
fi

echo "✅ Created Xcode project templates."
echo ""
echo "===== INSTRUCTIONS FOR CREATING THE NEW XCODE PROJECT ====="
echo ""
echo "1. Launch Xcode"
echo "2. Select 'Create a new Xcode project'"
echo "3. Choose 'App' under macOS templates"
echo "4. Configure your new project:"
echo "   - Product Name: OpenPage"
echo "   - Organization Identifier: deepskandpal (to match previous bundle ID)"
echo "   - Interface: SwiftUI"
echo "   - Language: Swift"
echo "   - Include Tests: Yes (keep consistent with original project)"
echo "5. Save the project to a TEMPORARY location (not in your OpenPage directory)"
echo ""
echo "6. After creating the project:"
echo "   - Close Xcode"
echo "   - Copy the OpenPage.xcodeproj/project.pbxproj from the temporary location to your OpenPage.xcodeproj directory"
echo "   - Open the project again and add existing files from the OpenPage directory:"
echo "     - Select File > Add Files to 'OpenPage'..."
echo "     - Select all files in the OpenPage directory"
echo "     - Make sure 'Create groups' is selected"
echo "     - Click 'Add'"
echo ""
echo "7. Configure project settings:"
echo "   - Update Bundle Identifier to: deepskandpal.OpenPage"
echo "   - Import the OpenPage.entitlements file"
echo "   - Set deployment target to macOS 14.0+"
echo ""
echo "8. Build and run the project to verify it works correctly"
echo ""
echo "The project.pbxproj.template file may be helpful for reference, but direct copying is not recommended"
echo "as Xcode project files are complex and can cause issues if not properly integrated."

echo ""
echo "Done." 