#!/usr/bin/env bash
out=$(playerctl metadata --format "  {{artist}} — {{title}}" 2>/dev/null)
if [ -n "$out" ]; then
    echo "$out"
fi
