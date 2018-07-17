#!/bin/bash

set -e

tool_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

cd "$tool_dir"

rm -rf build
mkdir build
cd build

ccache -s

export PATH="/usr/lib/ccache/bin/:$PATH"
export CC="clang"
export CXX="clang++"

cmake -DLLVM_ENABLE_MODULES=On -DCMAKE_BUILD_TYPE=Release -GNinja ../llvm

ionice -t -c 3 nice -n 19 ninja -j2
