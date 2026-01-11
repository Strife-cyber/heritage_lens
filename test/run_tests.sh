#!/bin/bash

# Heritage Lens - Test Runner Script
# This script runs all tests and generates a summary

set -e

echo "================================================"
echo "Heritage Lens - Test Suite Runner"
echo "================================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Error: Flutter is not installed or not in PATH${NC}"
    exit 1
fi

echo "Flutter version:"
flutter --version
echo ""

# Get dependencies
echo "================================================"
echo "Installing dependencies..."
echo "================================================"
flutter pub get
echo ""

# Run all tests
echo "================================================"
echo "Running all tests..."
echo "================================================"
if flutter test; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    TEST_RESULT=0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    TEST_RESULT=1
fi
echo ""

# Run tests with coverage if requested
if [ "$1" == "--coverage" ]; then
    echo "================================================"
    echo "Generating coverage report..."
    echo "================================================"
    flutter test --coverage
    
    if command -v lcov &> /dev/null; then
        echo "Generating HTML coverage report..."
        genhtml coverage/lcov.info -o coverage/html
        echo -e "${GREEN}Coverage report generated in coverage/html/index.html${NC}"
    else
        echo -e "${YELLOW}Warning: lcov not installed. Install it to generate HTML coverage reports.${NC}"
    fi
    echo ""
fi

# Test file count
TEST_FILE_COUNT=$(find test -name "*_test.dart" | wc -l)
echo "================================================"
echo "Test Summary"
echo "================================================"
echo "Test files found: $TEST_FILE_COUNT"
echo ""

# List all test files
echo "Test files:"
find test -name "*_test.dart" | sort | sed 's/^/  - /'
echo ""

if [ $TEST_RESULT -eq 0 ]; then
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN}✓ All tests completed successfully!${NC}"
    echo -e "${GREEN}================================================${NC}"
    exit 0
else
    echo -e "${RED}================================================${NC}"
    echo -e "${RED}✗ Test suite failed${NC}"
    echo -e "${RED}================================================${NC}"
    exit 1
fi