#!/bin/bash

# Test runner for Circular Brick Breaker
# This script runs the unit tests in the Playdate Simulator

echo "Running Circular Brick Breaker Unit Tests..."
echo ""

# Create a temporary main.lua that just loads the tests
cat > Source/main-test.lua << 'EOF'
import "CoreLibs/object"
import "CoreLibs/graphics"
import "tests"
EOF

# Build the test version
echo "Building test version..."
pdc Source Build/BrickBreakerTests.pdx

# Clean up
rm Source/main-test.lua

if [ $? -eq 0 ]; then
  echo ""
  echo "✓ Tests built successfully!"
  echo ""
  echo "To run tests, open Build/BrickBreakerTests.pdx in the Playdate Simulator"
  echo "and check the console output."
else
  echo ""
  echo "✗ Test build failed"
  exit 1
fi
