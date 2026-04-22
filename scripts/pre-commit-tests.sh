#!/bin/bash
##############################################################################
# Pre-commit Testing Script - Mobile
#
# This script runs mobile (Flutter/Dart) tests before committing.
# Runs only in the mobile repository context.
#
##############################################################################

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Functions
print_header() {
  echo ""
  echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║  $1${NC}"
  echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
}

print_section() {
  echo -e "${CYAN}► $1${NC}"
}

run_with_timing() {
  local cmd="$1"
  local desc="$2"
  local start_time=$(date +%s)

  echo -e "${YELLOW}  Running: ${desc}${NC}"

  if eval "$cmd" 2>&1; then
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    echo -e "${GREEN}  ✅ ${desc} (${duration}s)${NC}"
    return 0
  else
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    echo -e "${RED}  ❌ ${desc} (${duration}s)${NC}"
    return 1
  fi
}

# Main execution
main() {
  print_header "Mobile Pre-commit Tests"

  local total_start=$(date +%s)
  local failed_tests=()

  print_section "Flutter/Dart Tests"

  # Check Flutter installation
  if ! command -v flutter >/dev/null 2>&1; then
    echo -e "${YELLOW}  ⚠️  Flutter is not installed or not in PATH${NC}"
    echo -e "${YELLOW}  To enable tests, install Flutter SDK${NC}"
  else
    # Get dependencies
    if ! run_with_timing "flutter pub get" "Get dependencies"; then
      failed_tests+=("dependencies")
    fi

    # Run tests
    if ! run_with_timing "flutter test" "Unit tests"; then
      failed_tests+=("tests")
    fi

    # Code analysis
    if ! run_with_timing "flutter analyze" "Code analysis"; then
      failed_tests+=("analysis")
    fi
  fi

  # Summary
  local total_end=$(date +%s)
  local total_duration=$((total_end - total_start))

  print_header "Results"

  if [ ${#failed_tests[@]} -eq 0 ]; then
    echo -e "${GREEN}🎉 All mobile tests passed! (${total_duration}s)${NC}"
    echo ""
    exit 0
  else
    echo -e "${RED}❌ Tests failed: ${failed_tests[*]} (${total_duration}s)${NC}"
    echo ""
    echo -e "${YELLOW}To skip: git commit --no-verify${NC}"
    echo ""
    exit 1
  fi
}

main "$@"
