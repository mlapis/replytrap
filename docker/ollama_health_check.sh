#!/bin/bash

if [[ -f /tmp/ollama_ready ]]; then
    exit 0
fi

if ollama list | grep -q 'llama3.2:3b'; then
    touch /tmp/ollama_ready
    exit 0
else
    exit 1
fi