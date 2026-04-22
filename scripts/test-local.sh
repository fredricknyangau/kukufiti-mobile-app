#!/bin/bash
##############################################################################
# Local Development Testing Script
#
# This script runs tests locally without Docker for faster development.
# Use this for quick testing during development.
#
# Usage:
#   ./scripts/test-local.sh [--backend] [--mobile] [--frontend] [--all]
#
##############################################################################

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default settings
RUN_BACKEND=true
RUN_MOBILE=true
RUN_FRONTEND=true

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --backend)
      RUN_BACKEND=true
      RUN_MOBILE=false
      RUN_FRONTEND=false
      shift
      ;;
    --mobile)
      RUN_BACKEND=false
      RUN_MOBILE=true
      RUN_FRONTEND=false
      shift
      ;;
    --frontend)
      RUN_BACKEND=false
      RUN_MOBILE=false
      RUN_FRONTEND=true
      shift
      ;;
    --all)
      RUN_BACKEND=true
      RUN_MOBILE=true
      RUN_FRONTEND=true
      shift
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      exit 1
      ;;
  esac
done

print_header() {
  echo ""
  echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
  echo -e "${BLUE}   $1${NC}"
  echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
}

run_test() {
  local cmd="$1"
  local desc="$2"

  echo -e "${YELLOW}Running: ${desc}${NC}"
  echo -e "${YELLOW}Command: ${cmd}${NC}"

  if eval "$cmd"; then
    echo -e "${GREEN}✅ ${desc} passed${NC}"
    return 0
  else
    echo -e "${RED}❌ ${desc} failed${NC}"
    return 1
  fi
}

main() {
  print_header "Local Development Tests"

  local failed_tests=()

  # Backend (local Python testing)
  if [ "$RUN_BACKEND" = true ]; then
    print_header "Backend Tests (Local Python)"

    cd backend

    # Check if Python virtual environment exists
    if [ -d "venv" ]; then
      source venv/bin/activate
      echo -e "${YELLOW}Using virtual environment${NC}"
    fi

    # Run pytest directly (if available)
    if command -v pytest >/dev/null 2>&1; then
      if ! run_test "pytest tests/ -v" "Backend pytest tests"; then
        failed_tests+=("backend-tests")
      fi
    else
      echo -e "${YELLOW}⚠️  pytest not found, skipping backend tests${NC}"
      echo -e "${YELLOW}   Install: pip install pytest${NC}"
    fi

    # Run basic Python syntax check
    if ! run_test "python -m py_compile app/main.py" "Backend syntax check"; then
      failed_tests+=("backend-syntax")
    fi

    cd ..
  fi

  # Mobile
  if [ "$RUN_MOBILE" = true ]; then
    print_header "Mobile Tests (Flutter)"

    cd mobile

    if command -v flutter >/dev/null 2>&1; then
      # Quick syntax check (faster than full test)
      if ! run_test "flutter analyze --no-pub" "Mobile code analysis"; then
        failed_tests+=("mobile-analyze")
      fi

      # Run a single test file if it exists
      if [ -f "test/widget_test.dart" ]; then
        if ! run_test "flutter test test/widget_test.dart" "Mobile basic test"; then
          failed_tests+=("mobile-test")
        fi
      fi
    else
      echo -e "${YELLOW}⚠️  Flutter not found, skipping mobile tests${NC}"
    fi

    cd ..
  fi

  # Frontend
  if [ "$RUN_FRONTEND" = true ]; then
    print_header "Frontend Tests (React)"

    cd frontend

    if command -v npm >/dev/null 2>&1; then
      if ! run_test "npm run lint" "Frontend linting"; then
        failed_tests+=("frontend-lint")
      fi

      # TypeScript check
      if ! run_test "npm run build" "Frontend build check"; then
        failed_tests+=("frontend-build")
      fi
    else
      echo -e "${YELLOW}⚠️  npm not found, skipping frontend tests${NC}"
    fi

    cd ..
  fi

  # Results
  print_header "Test Results"

  if [ ${#failed_tests[@]} -eq 0 ]; then
    echo -e "${GREEN}🎉 All local tests passed!${NC}"
    echo ""
    echo -e "${YELLOW}Ready to commit! Run:${NC}"
    echo "  git add ."
    echo "  git commit -m 'your message'"
    exit 0
  else
    echo -e "${RED}❌ Some tests failed: ${failed_tests[*]}${NC}"
    echo ""
    echo -e "${YELLOW}Fix issues or use:${NC}"
    echo "  git commit --no-verify -m 'your message'"
    exit 1
  fi
}

main "$@"
