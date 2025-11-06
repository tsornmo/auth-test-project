#!/bin/bash

# Convenience script - shorter alias for manage.sh
# Usage: ./app <command> [options]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/manage.sh" "$@"