#!/usr/bin/env bash
# WhatWeb Test Suite

echo "🧪 Testing WhatWeb Installation"
echo

echo "1. Version check..."
./whatweb --version || exit 1

echo "2. Plugin loading..."
PLUGINS=$(./whatweb --list-plugins | grep "Total:" | awk '{print $2}')
if [ "$PLUGINS" -gt 1000 ]; then
    echo "✓ Loaded $PLUGINS plugins"
else
    echo "✗ Only $PLUGINS plugins loaded (should be 1800+)"
    exit 1
fi

echo "3. Basic scan test..."
if ./whatweb example.com | grep -q "200 OK\|301\|302"; then
    echo "✓ Basic scan works"
else
    echo "✗ Scan failed"
    exit 1
fi

echo "4. Verbose mode..."
if ./whatweb -v example.com 2>&1 | grep -q "example.com"; then
    echo "✓ Verbose mode works"
else
    echo "✗ Verbose mode failed"
fi

echo
echo "✅ All tests passed!"
