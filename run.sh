#!/bin/bash

set -e

tool_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd "$tool_dir"

git pull
bash update_lldb.sh
bash build_lldb.sh
bash make_bench.sh
rm -rf build
