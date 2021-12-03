# Day 01
utils/bf-int: utils/bf-int.cpp
	g++ -O3 utils/bf-int.cpp -o utils/bf-int

day01: utils/bf-int

run-day01: day01
	./utils/bf-int day01-part1.bf inputs/day01.in
	./utils/bf-int day01-part2.bf inputs/day01.in

# Day 02
day02: day02.f90
	gfortran -o $@ $^

run-day02: day02
	./day02 <inputs/day02.in

day03:
	cd day03 && dotnet build

run-day03:
	cd day03 && dotnet run -- ../inputs/day03.in

clean:
	rm day02

.PHONY: clean day03
