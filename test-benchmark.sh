#!/bin/bash

bench_dir=${1?Need a path to a bench dir}
lldb_bin=${2:-lldb}
echo "Using lldb $lldb_bin"
set -e
cd "$bench_dir"
old_dir=`pwd`
cd ..
cp -r "$old_dir/" .tmp_dir
cd .tmp_dir
cmake -DCMAKE_BUILD_TYPE=Debug -GNinja .
ninja
if hash time 2>/dev/null; then
  time $lldb_bin -s commands.lldb -o quit
else
  $lldb_bin -s commands.lldb -o quit
fi
