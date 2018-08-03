#!/bin/bash

set -e

tool_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

cd "$tool_dir"

rm -rf build
mkdir build
cd build

ccache -s

#export PATH="/usr/lib/ccache/bin/:$PATH"
export CC="clang"
export CXX="clang++"

#-DLLVM_ENABLE_MODULES=On
cmake -DLLVM_PARALLEL_LINK_JOBS=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo -DLLVM_LINK_LLVM_DYLIB=On -GNinja ../llvm

ionice -t -c 3 nice -n 19 ninja -j2 lldb clang
