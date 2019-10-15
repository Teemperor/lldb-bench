set terminal svg size 1200,800  enhanced background rgb 'white'
set output 'benchmark.svg'

set multiplot layout 2,1 rowsfirst

set style line 1 lc rgb '#0060ad' lt 1 lw 2 pt 7 pi -1 ps 0.5
set style line 2 lc rgb '#6000ad' lt 1 lw 2 pt 7 pi -1 ps 0.5
set style line 3 lc rgb '#ad6000' lt 1 lw 2 pt 7 pi -1 ps 0.5

set title "Benchmark: BENCH_NAME"
set style data fsteps
set xlabel "Date\n"
set timefmt '%Y-%m-%d'
set yrange [ 0 : ]
set xdata time
set xrange [time(0) - 79*24*60*60:]
set xtics rotate by 45 offset -3, -3
set ylabel "Instructions"
set format x "%Y-%m-%d"
set grid
set key left bottom
plot 'inst.dat' using 1:4 t 'instructions' with linespoints ls 1

set style line 1 lc rgb '#ad6000' lt 1 lw 2 pt 7 pi -1 ps 0.5
set style line 2 lc rgb '#ad6000' lt 1 lw 2 pt 7 pi -1 ps 0.5
set style line 3 lc rgb '#ad6000' lt 1 lw 2 pt 7 pi -1 ps 0.5

#set title "Memory of BENCH_NAME"
set style data fsteps
set xlabel "Date\n"
set timefmt '%Y-%m-%d'
set yrange [ 0 : ]
set xdata time
set xrange [time(0) - 79*24*60*60:]
set xtics rotate by 45 offset -3, -3
set ylabel "Memory in kB"
set format x "%Y-%m-%d"
set grid
set key left bottom
plot 'mem.dat' using 1:4 t 'memory' with linespoints ls 1
