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

make_profile_single() {
  echo "Profiling $1"

  safe_name="$1"
  command="$tool_dir/build/bin/lldb -S commands.lldb -- ./a.out"
  runs="5"

  # Record instructions
  rm -f $tmp_dir/runtime_instructions.all

  echo "Profiling using instructions of $safe_name..."
  for run in `seq $runs`;
  do
    echo "Iteration $run"
    bash -c "perf stat -e instructions:u $command" 2>"$tmp_dir/perf_out" 1>/dev/null
    cat $tmp_dir/perf_out | grep instructions:u | awk '{print $1}' | tr -d "," >> $tmp_dir/runtime_instructions.all
  done
  ~/make_average.py $tmp_dir/runtime_instructions.all $tmp_dir/runtime_instructions
  runtime_inst=`cat $tmp_dir/runtime_instructions | tr -d '[:space:]'`

  echo "Profiling memory of $safe_name..."
  # Record memory
  rm -f $tmp_dir/runtime_mem.all
  for run in `seq $runs`;
  do
    echo "Iteration $run"
    bash -c "/usr/bin/time -v -o $tmp_dir/runtime_mem_tmp $command" 1>/dev/null 2>/dev/null
    cat "$tmp_dir/runtime_mem_tmp" | grep "Maximum resident set size" | awk '{print $6}' >> $tmp_dir/runtime_mem.all
  done
  ~/make_average.py $tmp_dir/runtime_mem.all $tmp_dir/runtime_mem
  runtime_mem=`cat $tmp_dir/runtime_mem | tr -d '[:space:]'`

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
  cp benchmark.svg "$output_dir/$safe_name.svg"
  html='<img class="benchmark" src="https://teemperor.de/lldb-bench/safe_name.svg" height="100%" style="display: none;">'
  html=${html/safe_name/$safe_name}
  echo "$html">> "$output_dir/index.new.html"
}

cp prefix.html "$output_dir/index.new.html"

while read -r line; do
  cd "$benchmark_dir/$line"
  make_profile_single "$line"
  cd "$tool_dir"
done <<< `ls $benchmark_dir`

cat suffix.html >> "$output_dir/index.new.html"
mv "$output_dir/index.new.html" "$output_dir/index.html"
