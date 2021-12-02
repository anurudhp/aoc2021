# Day 01
utils/bf-int: utils/bf-int.cpp
	g++ -O3 utils/bf-int.cpp -o utils/bf-int

day01: utils/bf-int

run-day01: day01
	./utils/bf-int day01-part1.bf inputs/day01.in
	./utils/bf-int day01-part2.bf inputs/day01.in

clean:

.PHONY: clean run-day01
