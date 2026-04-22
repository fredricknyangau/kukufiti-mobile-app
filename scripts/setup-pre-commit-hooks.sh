#!/bin/bash
##############################################################################
# Pre-commit Hook Setup Script
#
# This script installs the pre-commit hook for each repository in the project.
# The hook will run tests automatically before each commit.
#
# Usage:
#   ./scripts/setup-pre-commit-hooks.sh
#
##############################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}Setting up pre-commit hooks for all repositories...${NC}"

# Function to setup hook for a repository
setup_hook() {
  local repo_path="$1"
  local repo_name="$2"

  if [ ! -d "$repo_path/.git" ]; then
    echo -e "${RED}❌ $repo_name: Not a git repository${NC}"
    return 1
  fi

  local hook_file="$repo_path/.git/hooks/pre-commit"

  # Copy the hook
  cp "$REPO_ROOT/scripts/pre-commit-hook.sh" "$hook_file"
  chmod +x "$hook_file"

  echo -e "${GREEN}✅ $repo_name: Pre-commit hook installed${NC}"
}

# Setup hooks for each repository
setup_hook "$REPO_ROOT/../backend" "Backend"
setup_hook "$REPO_ROOT" "Mobile"
setup_hook "$REPO_ROOT/../frontend" "Frontend"

echo ""
echo -e "${GREEN}🎉 Pre-commit hooks setup complete!${NC}"
echo ""
echo -e "${YELLOW}What happens now:${NC}"
echo "  • Tests run automatically before each commit"
echo "  • Failed tests prevent commits"
echo "  • Use 'git commit --no-verify' to skip (not recommended)"
echo ""
echo -e "${YELLOW}Test commands:${NC}"
echo "  • Mobile only: ./scripts/pre-commit-tests.sh --mobile"
