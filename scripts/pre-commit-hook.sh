#!/bin/bash
##############################################################################
# Pre-commit Git Hook
#
# This hook runs automatically before each commit to ensure code quality.
# It runs all tests across the monorepo to prevent broken commits.
#
# To install:
#   cp scripts/pre-commit-hook.sh .git/hooks/pre-commit
#   chmod +x .git/hooks/pre-commit
#
# To skip tests (not recommended):
#   git commit --no-verify -m "message"
#
##############################################################################

# Get the root directory of the git repository
REPO_ROOT=$(git rev-parse --show-toplevel)
HOOK_SCRIPT="$REPO_ROOT/scripts/pre-commit-tests.sh"

if [ ! -f "$HOOK_SCRIPT" ]; then
  echo "Pre-commit test script not found: $HOOK_SCRIPT"
  exit 1
fi

# Run from the mobile repo so Flutter commands use the correct pubspec.
cd "$REPO_ROOT"

# Run the pre-commit tests script
bash "$HOOK_SCRIPT"

# Exit with the same code as the test script
exit $?
