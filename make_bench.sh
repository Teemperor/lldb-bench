set -e

tool_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

cd "$tool_dir"
cd "llvm/tools/lldb/"
git_time=`date "+%F %H:%M"`
git_commit=`git log -1 --format="%H" `
cd "$tool_dir"

benchmark_dir="benchmarks_build"
rm -rf "$benchmark_dir"
cp -r benchmarks "$benchmark_dir"

output_dir="/var/www/lldb-bench/"
data_out_dir="/var/www/lldb-bench/data/"

benchmark_directories=`find $benchmark_dir -mindepth 1 -maxdepth 1`

export CC="$tool_dir/build/bin/clang"
export CXX="$tool_dir/build/bin/clang++"

while read -r line; do
  echo "Building $line"
  cd "$line"
  cmake -GNinja -DCMAKE_BUILD_TYPE=Debug . >> build.log
  ninja >> build.log
  cd "$tool_dir"
done <<< "$benchmark_directories"

tmp_dir=`realpath ~/tmp/`
record_dir=`realpath ~/records/`

mkdir -p "$tmp_dir"
mkdir -p "$record_dir"

makeflamegraph() {
  outfile="$1"
  shift
  perf record -F 1000 --call-graph dwarf -- "$@" > /dev/null
  perf script | stackcollapse-perf.pl > .out.perf-folded
  flamegraph.pl .out.perf-folded > "$outfile"
  rm .out.perf-folded
}

make_profile_single() {
  echo "Profiling $1"

  safe_name="$1"
  command="$tool_dir/build/bin/lldb -x -S commands.lldb -o quit"
  runs="5"

  # Record instructions
  rm -f $tmp_dir/runtime_instructions.all

  pwd
  echo "Profiling using instructions of $safe_name... "
  for run in `seq $runs`;
  do
    echo -n " *"
    bash -c "perf stat -e instructions:u $command" 2>"$tmp_dir/perf_out" 1>stdout.log
    cat $tmp_dir/perf_out | grep instructions:u | awk '{print $1}' | tr -d "," >> $tmp_dir/runtime_instructions.all
  done
  echo ""
  ~/make_average.py $tmp_dir/runtime_instructions.all $tmp_dir/runtime_instructions
  runtime_inst=`cat $tmp_dir/runtime_instructions | tr -d '[:space:]'`

  echo "Profiling memory of $safe_name... "
  # Record memory
  rm -f $tmp_dir/runtime_mem.all
  for run in `seq $runs`;
  do
    echo -n " *"
    bash -c "/usr/bin/time -v -o $tmp_dir/runtime_mem_tmp $command" 1>stdout.log 2>stderr.log
    cat "$tmp_dir/runtime_mem_tmp" | grep "Maximum resident set size" | awk '{print $6}' >> $tmp_dir/runtime_mem.all
  done
  echo ""
  ~/make_average.py $tmp_dir/runtime_mem.all $tmp_dir/runtime_mem
  runtime_mem=`cat $tmp_dir/runtime_mem | tr -d '[:space:]'`

  echo "Making flamegraph"
  graph_file="$data_out_dir/safe_name.svg"
  graph_file=${graph_file/safe_name/$safe_name}
  makeflamegraph "$graph_file" $command

  echo "$git_time $git_commit $runtime_mem" >> $record_dir/lldb-$safe_name.mem.dat
  echo "$git_time $git_commit $runtime_inst" >> $record_dir/lldb-$safe_name.inst.dat
  sort $record_dir/lldb-$safe_name.mem.dat -o $record_dir/lldb-$safe_name.mem.dat
  sort $record_dir/lldb-$safe_name.inst.dat -o $record_dir/lldb-$safe_name.inst.dat

  cp $record_dir/lldb-$safe_name.mem.dat $tmp_dir/mem.dat
  cp $record_dir/lldb-$safe_name.inst.dat $tmp_dir/inst.dat

  cp ~/template.gp "$tmp_dir/plot.gp"
  ~/setup_bench.py "$tmp_dir/plot.gp" "$1"
  cd "$tmp_dir"
  gnuplot plot.gp
  chmod 755 benchmark.svg

  # Append git commit to safe name to fix caching issues on browsers.
  pure_safe_name="$safe_name"
  safe_name="$safe_name.$git_commit"
  cp benchmark.svg "$output_dir/$safe_name.svg"
  html='<a style="display: none;" href="https://teemperor.de/lldb-bench/data/pure_safe_name.svg" class="benchmark"><img src="https://teemperor.de/lldb-bench/safe_name.svg" height="100%"></a>'
  html=${html/pure_safe_name/$pure_safe_name}
  html=${html/safe_name/$safe_name}
  echo "$html">> "$output_dir/index.new.html"

  html='<a href="https://teemperor.de/lldb-bench/data/pure_safe_name.svg" class="benchmark"><img src="https://teemperor.de/lldb-bench/safe_name.svg" height="100%""></a>'
  html=${html/pure_safe_name/$pure_safe_name}
  html=${html/safe_name/$safe_name}
  echo "$html">> "$output_dir/static.new.html"
}

echo "Generating prefix"
cp prefix.html "$output_dir/index.new.html"
cp prefix-static.html "$output_dir/static.new.html"

cd "$tool_dir"

for bench in $benchmark_dir/* ; do
  bench=$(basename $bench)
  echo "Benchmarking $bench"
  cd "$benchmark_dir/$bench"
  make_profile_single "$bench"
  cd "$tool_dir"
done

echo "Appending suffix"
cat suffix.html >> "$output_dir/index.new.html"
cat suffix.html >> "$output_dir/static.new.html"
echo "Moving HTML report to destination"
mv "$output_dir/index.new.html" "$output_dir/index.html"
mv "$output_dir/static.new.html" "$output_dir/static.html"

cp $record_dir/* "$data_out_dir/"
cd "$data_out_dir"
git add *.dat
git commit -am "Added stats for lldb commit $git_commit"
