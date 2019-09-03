#!/bin/bash

set -e

tool_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

cd "$tool_dir"

cd llvm-project/
git fetch --all ; git pull
