#!/bin/bash

echo "Fixing POSGO project structure..."

# Create proper directory structure
mkdir -p POSGO/Sources
mkdir -p POSGO/Tests

# Move Swift files to Sources (excluding tests)
mv *.swift POSGO/Sources/ 2>/dev/null || true
mv Contents.json POSGO/Sources/ 2>/dev/null || true

# Move test files to Tests
mv POSGOTests POSGO/Tests/ 2>/dev/null || true
mv POSGOUITests POSGO/Tests/ 2>/dev/null || true

echo "Project structure fixed!"
echo "Now open POSGO.xcodeproj in Xcode" 