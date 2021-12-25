use std::io;

fn input() -> Vec<Vec<char>> {
    let mut grid = Vec::new();

    let mut done = false;
    while !done {
        let mut buf = String::new();
        match io::stdin().read_line(&mut buf) {
            Ok(..) => {
                if buf.len() == 0 {
                    done = true;
                } else {
                    grid.push(buf.trim().chars().collect());
                }
            }
            Err(..) => {
                done = true;
            }
        }
    }

    return grid;
}

fn step_right(grid: &mut Vec<Vec<char>>) -> bool {
    let n = grid.len();
    let m = grid[0].len();

    let mut cpy = Vec::new();
    for i in 0..n {
        cpy.push(grid[i].clone());
    }

    let mut upd = false;
    for i in 0..n {
        for j in 0..m {
            if grid[i][j] == '>' && cpy[i][(j + 1) % m] == '.' {
                upd = true;
                grid[i][j] = '.';
                grid[i][(j + 1) % m] = '*';
            }
        }
    }
    for i in 0..n {
        for j in 0..m {
            if grid[i][j] == '*' {
                grid[i][j] = '>';
            }
        }
    }
    return upd;
}

fn step_down(grid: &mut Vec<Vec<char>>) -> bool {
    let n = grid.len();
    let m = grid[0].len();

    let mut cpy = Vec::new();
    for i in 0..n {
        cpy.push(grid[i].clone());
    }

    let mut upd = false;
    for i in 0..n {
        for j in 0..m {
            if grid[i][j] == 'v' && cpy[(i + 1) % n][j] == '.' {
                upd = true;
                grid[i][j] = '.';
                grid[(i + 1) % n][j] = '*';
            }
        }
    }
    for i in 0..n {
        for j in 0..m {
            if grid[i][j] == '*' {
                grid[i][j] = 'v';
            }
        }
    }
    return upd;
}

fn step(grid: &mut Vec<Vec<char>>) -> bool {
    let r = step_right(grid);
    let d = step_down(grid);
    return r || d;
}

fn main() {
    let mut grid = input();
    let mut i = 0;
    while step(&mut grid) {
        i += 1;
    }
    println!("{}", i + 1);
}
