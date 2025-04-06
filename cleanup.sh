#!/bin/bash

# This script removes all original files and directories after successful restructuring
# CAUTION: Only run this after verifying that the new OpenPage project builds and runs correctly

echo "⚠️  CAUTION: This script will delete original files and directories."
echo "Only run this after verifying that the new OpenPage project works correctly."
echo "Press CTRL+C to cancel or any key to continue..."
read -n 1

echo "Backing up data first..."
timestamp=$(date +"%Y%m%d_%H%M%S")
mkdir -p backup_$timestamp

# Backup key directories and files
cp -R writing_app backup_$timestamp/ 2>/dev/null || echo "writing_app not backed up"
cp -R Models backup_$timestamp/ 2>/dev/null || echo "Models not backed up"
cp -R Views backup_$timestamp/ 2>/dev/null || echo "Views not backed up"
cp -R ViewModels backup_$timestamp/ 2>/dev/null || echo "ViewModels not backed up"
cp -R Services backup_$timestamp/ 2>/dev/null || echo "Services not backed up"
cp -R writing_app.xcodeproj backup_$timestamp/ 2>/dev/null || echo "writing_app.xcodeproj not backed up"
cp -R writing_appTests backup_$timestamp/ 2>/dev/null || echo "writing_appTests not backed up"
cp -R writing_appUITests backup_$timestamp/ 2>/dev/null || echo "writing_appUITests not backed up"
cp writing_appApp.swift backup_$timestamp/ 2>/dev/null || echo "writing_appApp.swift not backed up"
cp writing_app.entitlements backup_$timestamp/ 2>/dev/null || echo "writing_app.entitlements not backed up"
cp ContentView.swift backup_$timestamp/ 2>/dev/null || echo "ContentView.swift not backed up"
cp Item.swift backup_$timestamp/ 2>/dev/null || echo "Item.swift not backed up"

echo "Backup created in backup_$timestamp/"
echo "Proceeding with deletion..."

# Remove original directories and files
rm -rf writing_app 2>/dev/null && echo "✓ Removed writing_app directory" || echo "✗ Failed to remove writing_app"
rm -rf Models 2>/dev/null && echo "✓ Removed Models directory" || echo "✗ Failed to remove Models"
rm -rf Views 2>/dev/null && echo "✓ Removed Views directory" || echo "✗ Failed to remove Views"
rm -rf ViewModels 2>/dev/null && echo "✓ Removed ViewModels directory" || echo "✗ Failed to remove ViewModels"
rm -rf Services 2>/dev/null && echo "✓ Removed Services directory" || echo "✗ Failed to remove Services"
rm -rf writing_app.xcodeproj 2>/dev/null && echo "✓ Removed writing_app.xcodeproj" || echo "✗ Failed to remove writing_app.xcodeproj"
rm -rf writing_appTests 2>/dev/null && echo "✓ Removed writing_appTests directory" || echo "✗ Failed to remove writing_appTests"
rm -rf writing_appUITests 2>/dev/null && echo "✓ Removed writing_appUITests directory" || echo "✗ Failed to remove writing_appUITests"
rm writing_appApp.swift 2>/dev/null && echo "✓ Removed writing_appApp.swift" || echo "✗ Failed to remove writing_appApp.swift"
rm writing_app.entitlements 2>/dev/null && echo "✓ Removed writing_app.entitlements" || echo "✗ Failed to remove writing_app.entitlements"
rm ContentView.swift 2>/dev/null && echo "✓ Removed ContentView.swift" || echo "✗ Failed to remove ContentView.swift"
rm Item.swift 2>/dev/null && echo "✓ Removed Item.swift" || echo "✗ Failed to remove Item.swift"

echo "Cleanup complete."
echo "If you need to restore files, they are available in backup_$timestamp/" 