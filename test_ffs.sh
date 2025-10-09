#!/usr/bin/env zsh
# Test script for the ffs function

# Source the ffs function
source ./ffs.zsh

echo "Testing ffs function..."
echo ""

# Test 1: Basic functionality
echo "Test 1: Simulate running a command that would need sudo"
echo "$ echo 'This would need sudo'"
echo "This would need sudo"
echo ""
echo "Now running ffs to execute with sudo:"
echo "$ ffs"

# We'll use a safe command that doesn't actually require sudo for testing
echo "test command" > /tmp/test_ffs_output.txt
ffs

echo ""
echo "---"
echo ""

# Test 2: Verify it doesn't run ffs recursively
echo "Test 2: Try to run ffs after ffs (should fail)"
echo "$ ffs"
ffs

echo ""
echo "Test complete!"
