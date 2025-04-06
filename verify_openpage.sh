#!/bin/bash

# Verify OpenPage Directory Structure

echo "OpenPage Directory Structure Verification"
echo "======================================="

# Check main directories
echo "Checking main directories..."
missing_dirs=0
for dir in Models Views ViewModels Services "Services/AI"; do
  if [ ! -d "OpenPage/$dir" ]; then
    echo "❌ Missing directory: OpenPage/$dir"
    missing_dirs=$((missing_dirs + 1))
  else
    echo "✅ Found directory: OpenPage/$dir"
  fi
done

if [ $missing_dirs -eq 0 ]; then
  echo "All required directories are present."
else
  echo "Missing $missing_dirs directories."
fi

# Check critical files
echo ""
echo "Checking critical files..."
missing_files=0
for file in "OpenPageApp.swift" "ContentView.swift" "Item.swift" "OpenPage.entitlements"; do
  if [ ! -f "OpenPage/$file" ]; then
    echo "❌ Missing file: OpenPage/$file"
    missing_files=$((missing_files + 1))
  else
    echo "✅ Found file: OpenPage/$file"
  fi
done

if [ $missing_files -eq 0 ]; then
  echo "All critical files are present."
else
  echo "Missing $missing_files critical files."
fi

# Check Xcode project structure
echo ""
echo "Checking Xcode project structure..."
if [ ! -d "OpenPage.xcodeproj" ]; then
  echo "❌ Missing OpenPage.xcodeproj directory"
else
  echo "✅ Found OpenPage.xcodeproj directory"
  
  if [ ! -f "OpenPage.xcodeproj/project.pbxproj" ]; then
    echo "❌ Missing project.pbxproj file (needed by Xcode)"
    echo "   Run create_xcode_project.sh and follow the instructions to create the Xcode project"
  else
    echo "✅ Found project.pbxproj file"
  fi
fi

# Print summary
echo ""
echo "===== SUMMARY ====="
if [ $missing_dirs -eq 0 ] && [ $missing_files -eq 0 ] && [ -d "OpenPage.xcodeproj" ] && [ -f "OpenPage.xcodeproj/project.pbxproj" ]; then
  echo "✅ All directories and files are ready for the new Xcode project."
else
  echo "⚠️ Some items are missing. Fix the issues above before proceeding."
fi

echo ""
echo "Recommended next steps:"
echo "1. Run create_xcode_project.sh to create a new Xcode project"
echo "2. Follow the step-by-step instructions provided by the script"
echo "3. Build and test the application"

echo ""
echo "Done." 