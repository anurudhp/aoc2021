package main

import (
	"bufio"
	"bytes"
	"encoding/gob"
	"fmt"
	"os"
)

func deepcopy(out, in interface{}) {
	buf := new(bytes.Buffer)
	gob.NewEncoder(buf).Encode(in)
	gob.NewDecoder(buf).Decode(out)
}

func stepAlong(grid [][]byte, c byte, di, dj int) bool {
	n := len(grid)
	m := len(grid[0])
  var cpy [][]byte
	deepcopy(&cpy, grid)
	upd := false

	for i := 0; i < n; i++ {
		for j := 0; j < m; j++ {
			if grid[i][j] == c && cpy[(i+di)%n][(j+dj)%m] == '.' {
				upd = true
				grid[i][j] = '.'
				grid[(i+di)%n][(j+dj)%m] = '*'
			}
		}
	}
	for i := 0; i < n; i++ {
		for j := 0; j < m; j++ {
			if grid[i][j] == '*' {
				grid[i][j] = c
			}
		}
	}
	return upd
}

func step(grid [][]byte) bool {
	d := stepAlong(grid, '>', 0, 1)
	r := stepAlong(grid, 'v', 1, 0)
	return d || r
}

func main() {
	scanner := bufio.NewScanner(os.Stdin)
	var grid [][]byte
	for scanner.Scan() {
		line := scanner.Text()
		row := make([]byte, len(line))
		for j := range row {
			row[j] = line[j]
		}
		grid = append(grid, row)
	}

	ans := 1
	for step(grid) {
		ans++
	}
	fmt.Println(ans)
}
