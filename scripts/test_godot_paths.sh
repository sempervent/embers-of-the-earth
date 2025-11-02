#!/bin/bash
# Script to help find and run Godot

echo "Searching for Godot installation..."
find /Applications -name "*Godot*" -type d 2>/dev/null | head -5
find ~/Applications -name "*Godot*" -type d 2>/dev/null | head -5

echo ""
echo "To run the game, you can:"
echo "1. Open Godot Editor"
echo "2. Import this project (project.godot)"
echo "3. Press F5 or click Play"
echo ""
echo "Or if Godot is installed, run:"
echo "godot --path ."
