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

# Day 13
day13.c: day13.lean
	lean -c $@ $^

day13.out: day13.c
	leanc -o $@ $^

run-day13: day13.out
	./$^ <inputs/day13.in

# Day 14
run-day14:
	cd day14 && spago run -b ../inputs/day14.in

# Day 15
run-day15:
	cd day15 && dotnet run -- ../inputs/day15.in

# Day 16
day16.out: day16.hs
	ghc-9.2.1 -o $@ $^

run-day16: day16.out
	./$^ <inputs/day16.in

# Day 17
run-day17:
	lua day17.lua <inputs/sample.in
	lua day17.lua <inputs/day17.in

# Day 18
day18.ml: day18.v
	coqc $^

day18.native: day18.ml
	ocamlbuild $@ -use-ocamlfind -package io-system

run-day18: day18.native
	./$^ inputs/day18.in

# Day 19
run-day19:
	node day19.js inputs/day19.in

# Day 20
day20: day20.zig
	zig build-exe $^

run-day20: day20
	./$^ <inputs/day20.in

# Day 21
day21.class: day21.sc
	scalac3 day21.sc

run-day21: day21.class
	scala3 day21 <inputs/day21.in

# Day 22
run-day22:
	julia day22.jl <inputs/day22.in

# Misc
clean:
	rm -f *.o utils/bf-int day02 day05 day08 day13.c day13.out \
		day16.out day16.hi
	rm -rf _build day18.ml* day18.vo* day18.glob day18.native
	rm -rf day20 zig-cache
	rm -rf day21*.class day21*.tasty

all: run-day01 run-day02 run-day03 run-day04 run-day05 \
     run-day06 run-day07 run-day08 run-day09 run-day10 \
     run-day11 run-day12 run-day13 run-day14 run-day15 \
     run-day16 run-day17 run-day18 run-day19 run-day20 \
     run-day21 run-day22

.PHONY: clean day03
