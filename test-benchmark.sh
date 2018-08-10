#!/bin/bash

bench_dir=${1?Need a path to a bench dir}
set -e
cd "$bench_dir"
old_dir=`pwd`
cd ..
cp -r "$old_dir/" .tmp_dir
cd .tmp_dir
cmake -DCMAKE_BUILD_TYPE=Debug -GNinja .
ninja
if hash time 2>/dev/null; then
  time lldb -s commands.lldb -o quit
else
  lldb -s commands.lldb -o quit
fi
