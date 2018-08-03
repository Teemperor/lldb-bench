# lldb-bench - A bunch of lldb benchmarks.

## How to add a benchmark

1. Go to the `benchmarks/` directory.
2. Add a new subfolder.
3. Add a CMakeLists.txt that compiles the files in the current folder.
4. Add a `commands.lldb` file containing a list of lldb commands to run.

*OR*

1. Copy `benchmarks/startup` to `benchmarks/<YOUR-BENCH-NAME>`.
2. Modify the `main.cpp` and `commands.lldb` for your needs.

## How to test a benchmark locally.

You can use test-benchmark.sh to test your benchmark for functionality.
E.g. to test the `print-str` benchmark, just run `bash test-benchmark.sh benchmarks/print-str/` from within the source directory.

## Limits for benchmarks.

A benchmark's runtime should be at most 30 seconds. This limit is set because each benchmark is
run multiple times and we take the average of the measurements. We also measure timing, memory and
flame graph stats in seperate runs to prevent them from influencing each other. So if youre benchmark
takes just 30 seconds to run once, it could still potentially run for half an hour or so on the server.
