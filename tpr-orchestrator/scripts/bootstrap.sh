#!/bin/bash
# bootstrap.sh - 自动激活脚本 (v1.0)
# Usage: ./scripts/bootstrap.sh

echo "Bootstrap process starting..."

# 1. Detect environment
CURRENT_USER=$(whoami)
CURRENT_DIR=$(pwd)
echo "Current User: $CURRENT_USER"
echo "Current Workspace: $CURRENT_DIR"

# 2. Path correction
# Reverse the placeholders used by the scrub tool
# Placeholder: /Users/${USER}/ -> Actual: /Users/current_user/

# We'll use a simple find and replace for the placeholder.
# In SCRUB_LIST.json, the placeholder search was "/Users/evan/" and replace was "/Users/${USER}/"
# So we need to replace "/Users/${USER}/" with "/Users/$CURRENT_USER/"

echo "Fixing environment placeholders..."
# Using the same file types as the scrub tool
find . -type f \( -name "*.md" -o -name "*.json" -o -name "*.sh" \) -not -path "./scripts/bootstrap.sh" -exec sed -i '' "s|/Users/\${USER}/|/Users/$CURRENT_USER/|g" {} + 2>/dev/null
# Also handle variations like /Users/$USER/
find . -type f \( -name "*.md" -o -name "*.json" -o -name "*.sh" \) -not -path "./scripts/bootstrap.sh" -exec sed -i '' "s|/Users/\$USER/|/Users/$CURRENT_USER/|g" {} + 2>/dev/null

# 3. Skill Scanning
echo "Scanning for local skills in workspace..."
if [ -d "skills" ]; then
    SKILLS_COUNT=$(ls -d skills/*/ 2>/dev/null | wc -l)
    echo "Found $SKILLS_COUNT local skills. These are now available to you."
    ls -d skills/*/ 2>/dev/null | xargs -n 1 basename
else
    echo "Warning: No 'skills/' directory found in this workspace. You might be a shell!"
fi

# 4. Handle openclaw.json specifically if needed
# (Optional) We could use JQ to update specific config fields if we know the schema.

# 4. Report status
echo "----------------------------------------"
echo "Activation Complete!"
echo "New Environment Context:"
echo "User: $CURRENT_USER"
echo "Workspace: $CURRENT_DIR"
echo "Status: READY"
echo "----------------------------------------"
echo "You can now delete BOOTSTRAP.md and start working."
