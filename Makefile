# Day 01
utils/bf-int: utils/bf-int.cpp
	g++ -O3 utils/bf-int.cpp -o utils/bf-int

run-day01: utils/bf-int
	./utils/bf-int day01-part1.bf inputs/day01.in
	./utils/bf-int day01-part2.bf inputs/day01.in

# Day 02
day02: day02.f90
	gfortran -o $@ $^

run-day02: day02
	./day02 <inputs/day02.in

# Day 03
day03:
	cd day03 && dotnet build

run-day03:
	cd day03 && dotnet run -- ../inputs/day03.in

# Day 04
run-day04:
	php day04.php <inputs/day04.in

# Day 05
day05: day05.d
	dmd day05.d

run-day05: day05
	./day05 <inputs/day05.in

# Day 06
run-day06:
	dyalog -script day06.apl

# Day 07
run-day07:
	Rscript --vanilla day07.R inputs/day07.in

# Day 08
day08: day08.pas
	fpc day08.pas

run-day08: day08
	./day08 <inputs/day08.in

# Day 09
run-day09:
	@echo "info: auto-run not supported."
	@echo "info: copy the script into matlab and run it."

# Day 10
run-day10:
	clojure -M day10.clj <inputs/day10.in

# Day 11
run-day11:
	java day11.java <inputs/day11.in

# Day 12
run-day12:
	ruby day12.rb <inputs/day12.in

# Misc
clean:
	rm -f *.o day02 day05 day08

all: run-day01 run-day02 run-day03 run-day04 run-day05 \
     run-day06 run-day07 run-day08 run-day09 run-day10 \
     run-day11 run-day12

.PHONY: clean day03
