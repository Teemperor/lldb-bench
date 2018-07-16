#!/bin/bash

set -e
git pull
bash update_lldb.sh
bash build_lldb.sh
bash make_bench.sh
