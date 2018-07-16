#!/usr/bin/env python

import sys

bench_file = sys.argv[1]
bench = sys.argv[2]

with open(bench_file, 'r') as file :
  filedata = file.read()
filedata = filedata.replace('BENCH_NAME', bench)
with open(bench_file, 'w') as file:
  file.write(filedata)
