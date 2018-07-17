#!/bin/bash

set -e

tool_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

cd "$tool_dir"

cd llvm
git fetch --all ; git pull

cd projects/libcxx
git fetch --all ; git pull

cd ../libcxxabi
git fetch --all ; git pull

cd ../../tools/clang
git fetch --all ; git pull

cd ../lldb
git fetch --all ; git pull

