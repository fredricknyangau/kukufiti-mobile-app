#!/bin/bash
##############################################################################
# Build Configuration Generator
# 
# This script generates build configuration for local development and testing
# It injects environment-specific API URLs and version information
#
# Usage:
#   ./scripts/generate_build_config.sh [--env dev|prod|local] [--api-url URL] [--version VERSION]
#
# Examples:
#   ./scripts/generate_build_config.sh --env dev
#   ./scripts/generate_build_config.sh --env prod --api-url https://api.prod.com
#   ./scripts/generate_build_config.sh --env local --api-url http://192.168.1.100:8080
#
##############################################################################

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
ENVIRONMENT="dev"
API_URL=""
VERSION=""
BUILD_NUMBER="${GITHUB_RUN_NUMBER:-0}"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --env)
      ENVIRONMENT="$2"
      shift 2
      ;;
    --api-url)
      API_URL="$2"
      shift 2
      ;;
    --version)
      VERSION="$2"
      shift 2
      ;;
    --build-number)
      BUILD_NUMBER="$2"
      shift 2
      ;;
    --help)
      grep '^#' "$0" | tail -n +2 | sed 's/^# //'
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      exit 1
      ;;
  esac
done

# Get base version from pubspec.yaml
get_base_version() {
  grep '^version:' pubspec.yaml | sed 's/version: //' | cut -d'+' -f1 | tr -d ' '
}

# Try to read from backend .env
read_env_value() {
  local key="$1"
  local file="$2"
  
  if [ ! -f "$file" ]; then
    return 1
  fi
  
  sed -n "s/^${key}=//p" "$file" | tail -n 1 | tr -d '\r' | sed 's/^"//; s/"$//'
}

# Set API URL based on environment
set_api_url() {
  if [ -n "$API_URL" ]; then
    return 0
  fi
  
  case "$ENVIRONMENT" in
    dev)
      API_URL=$(read_env_value "MOBILE_API_URL_DEV" "../backend/.env" 2>/dev/null || echo "")
      if [ -z "$API_URL" ]; then
        API_URL="http://localhost:8080/api/v1"
      fi
      ;;
    prod)
      API_URL=$(read_env_value "MOBILE_API_URL_PROD" "../backend/.env" 2>/dev/null || echo "")
      if [ -z "$API_URL" ]; then
        API_URL=$(read_env_value "MOBILE_API_URL" "../backend/.env" 2>/dev/null || echo "")
      fi
      ;;
    local)
      API_URL="http://10.0.2.2:8080/api/v1"
      ;;
    *)
      echo -e "${RED}Unknown environment: $ENVIRONMENT${NC}"
      exit 1
      ;;
  esac
  
  if [ -z "$API_URL" ]; then
    echo -e "${RED}Error: Could not determine API URL for environment '$ENVIRONMENT'${NC}"
    exit 1
  fi
}

# Main execution
main() {
  echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
  echo -e "${BLUE}   KukuFiti Build Configuration Generator${NC}"
  echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
  
  # Get version
  if [ -z "$VERSION" ]; then
    VERSION=$(get_base_version)
  fi
  
  # Set API URL
  set_api_url
  
  # Display configuration
  echo ""
  echo -e "${YELLOW}Configuration:${NC}"
  echo -e "  Environment: ${GREEN}$ENVIRONMENT${NC}"
  echo -e "  Version:     ${GREEN}$VERSION+$BUILD_NUMBER${NC}"
  echo -e "  API URL:     ${GREEN}$API_URL${NC}"
  echo ""
  
  # Generate Dart define arguments
  echo -e "${YELLOW}Generated Dart Defines:${NC}"
  DART_DEFINES="--dart-define=API_URL=$API_URL"
  echo -e "  ${GREEN}$DART_DEFINES${NC}"
  echo ""
  
  # Save to file for reference
  CONFIG_FILE=".build_config.env"
  cat > "$CONFIG_FILE" << EOF
# Generated build configuration - $(date)
ENVIRONMENT=$ENVIRONMENT
API_URL=$API_URL
VERSION=$VERSION
BUILD_NUMBER=$BUILD_NUMBER
DART_DEFINES=$DART_DEFINES
EOF
  
  echo -e "${GREEN}✅ Configuration saved to: $CONFIG_FILE${NC}"
  echo ""
  
  # Provide next steps
  echo -e "${YELLOW}Next Steps:${NC}"
  echo "  1. For development build:"
  echo -e "     ${GREEN}flutter build apk --release $DART_DEFINES --build-name=$VERSION --build-number=$BUILD_NUMBER${NC}"
  echo ""
  echo "  2. For development run:"
  echo -e "     ${GREEN}flutter run $DART_DEFINES${NC}"
  echo ""
}

# Execute main function
main "$@"
