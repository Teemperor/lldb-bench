#!/bin/bash

orig_dir=$(pwd)
bench_dir=${1?Need a path to a bench dir}
lldb_bin1=${2:-lldb}
lldb_bin2=${3:-lldb}
echo "Using lldb $lldb_bin"
set -e
cd "$bench_dir"
old_dir=`pwd`
cd ..
cp -r "$old_dir/" .tmp_dir
cd .tmp_dir
cmake -DCMAKE_BUILD_TYPE=Debug -GNinja .
ninja
if hash bench 2>/dev/null; then
  bench "$lldb_bin1 -s commands.lldb -o quit" "$lldb_bin2 -s commands.lldb -o quit" --output "$orig_dir/report.html"
else
  $lldb_bin -s commands.lldb -o quit
fi
