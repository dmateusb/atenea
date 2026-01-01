#!/bin/bash
# Automated git commit script following Conventional Commits

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Checking git status...${NC}"
git status --short

echo ""
echo -e "${BLUE}📝 Creating commit...${NC}"

# Get commit message from argument or use default
if [ -z "$1" ]; then
    COMMIT_MSG="chore: update code and documentation"
else
    COMMIT_MSG="$1"
fi

# Add all changes
git add .

# Create commit
git commit -m "$COMMIT_MSG"

echo ""
echo -e "${GREEN}✅ Commit created: $COMMIT_MSG${NC}"

# Ask if should push
read -p "Push to remote? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    git push origin main
    echo -e "${GREEN}✅ Pushed to remote${NC}"
else
    echo -e "${BLUE}ℹ️  Commit created locally. Push later with: git push origin main${NC}"
fi
