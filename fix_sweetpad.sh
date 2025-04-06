#!/bin/bash

# This script fixes SweetPad/Cursor configuration for OpenPage project

echo "Fixing SweetPad configuration for OpenPage project..."

# Update buildServer.json
if [ -f "buildServer.json" ]; then
  echo "✅ Updated buildServer.json"
  cat > buildServer.json << EOF
{
	"name": "xcode build server",
	"version": "0.2",
	"bspVersion": "2.0",
	"languages": [
		"c",
		"cpp",
		"objective-c",
		"objective-cpp",
		"swift"
	],
	"argv": [
		"/opt/homebrew/bin/xcode-build-server"
	],
	"workspace": "$(pwd)/OpenPage.xcodeproj/project.xcworkspace",
	"build_root": "$HOME/Library/Developer/Xcode/DerivedData/OpenPage",
	"scheme": "OpenPage",
	"kind": "xcode"
}
EOF
fi

# Create/update VS Code settings
mkdir -p .vscode
cat > .vscode/settings.json << EOF
{
    "sweetpad.build.xcodeWorkspacePath": "OpenPage.xcodeproj/project.xcworkspace", 
    "sweetpad.build.xcodeSchemeName": "OpenPage"
}
EOF
echo "✅ Updated VS Code settings"

# Clear any build caches
echo "Cleaning build caches..."
rm -rf .build/arm64-apple-macosx/debug/writing_app* 2>/dev/null
rm -rf ~/Library/Developer/Xcode/DerivedData/writing_app* 2>/dev/null

echo "✅ Configuration updated!"
echo ""
echo "Next steps:"
echo "1. Restart SweetPad/Cursor"
echo "2. If still encountering issues, try manually selecting the OpenPage scheme in Xcode"
echo "   then restarting SweetPad/Cursor again"
echo ""
echo "Done." 