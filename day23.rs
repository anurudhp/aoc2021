use std::collections::BinaryHeap;
use std::collections::HashMap;
use std::io;
use std::mem::swap;

#[derive(PartialEq, Eq, PartialOrd, Ord, Hash, Clone, Copy)]
struct State {
    rows: [[i8; 4]; 4],
    hall: [i8; 11],
}

impl State {
    pub fn new() -> Self {
        Self {
            rows: [[4; 4]; 4],
            hall: [-1; 11],
        }
    }
}

fn input() -> State {
    let mut pos = State::new();
    for i in 0..4 {
        let mut buf = String::new();
        io::stdin().read_line(&mut buf).expect("");
        if i < 2 {
            continue;
        }
        let buf: Vec<char> = buf.chars().collect();
        for j in [3, 5, 7, 9] {
            if let Some(d) = buf[j].to_digit(16) {
                pos.rows[i - 2][(j - 3) / 2] = d as i8 - 10;
            }
        }
    }
    pos
}

fn get_edges(u: State) -> Vec<(State, i32)> {
    let cost: Vec<i32> = vec![1, 10, 100, 1000];
    let mut edges = Vec::new();
    let mut v = u;
    for j in 0..4 {
        let c = 2 * (1 + j);
        // move out
        for i in 0..4 {
            if u.rows[i][j] == -1 {
                continue;
            }
            if u.rows[i][j] == 4 {
                break;
            }
            for p in c..11 {
                if u.hall[p] != -1 {
                    break;
                }
                if [2, 4, 6, 8].contains(&p) {
                    continue;
                }
                swap(&mut v.hall[p], &mut v.rows[i][j]);
                edges.push((v, cost[v.hall[p] as usize] * (p - c + i + 1) as i32));
                swap(&mut v.hall[p], &mut v.rows[i][j]);
            }
            for p in (0..c).rev() {
                if u.hall[p] != -1 {
                    break;
                }
                if [2, 4, 6, 8].contains(&p) {
                    continue;
                }
                swap(&mut v.hall[p], &mut v.rows[i][j]);
                edges.push((v, cost[v.hall[p] as usize] * (c - p + i + 1) as i32));
                swap(&mut v.hall[p], &mut v.rows[i][j]);
            }
            break;
        }
        // move in
        for i in (0..4).rev() {
            if u.rows[i][j] == 4 {
                continue;
            }
            if u.rows[i][j] != -1 {
                break;
            }

            for p in c..11 {
                if u.hall[p] == j as i8 {
                    v.hall[p] = -1;
                    v.rows[i][j] = 4;
                    edges.push((v, cost[j] * (p - c + i + 1) as i32));
                    v.hall[p] = j as i8;
                    v.rows[i][j] = -1;
                }
                if u.hall[p] != -1 {
                    break;
                }
            }
            for p in (0..c).rev() {
                if u.hall[p] == j as i8 {
                    v.hall[p] = -1;
                    v.rows[i][j] = 4;
                    edges.push((v, cost[j] * (c - p + i + 1) as i32));
                    v.hall[p] = j as i8;
                    v.rows[i][j] = -1;
                }
                if u.hall[p] != -1 {
                    break;
                }
            }
            break;
        }
    }
    edges
}

fn bfs<T: Ord + Copy + std::hash::Hash>(src: T, dst: T, adj: fn(T) -> Vec<(T, i32)>) -> i32 {
    let mut heap = BinaryHeap::new();
    let mut dis = HashMap::new();

    heap.push((0, src));
    dis.insert(src, 0);

    while !heap.is_empty() {
        if let Some((du, u)) = heap.pop() {
            let du = -du;
            if u == dst {
                return du;
            }
            if let Some(dd) = dis.get(&u) {
                if du != *dd {
                    continue;
                }
                for (v, w) in adj(u) {
                    if match dis.get(&v) {
                        Some(dv) => *dv > du + w,
                        None => true,
                    } {
                        dis.insert(v, du + w);
                        heap.push((-du - w, v));
                    }
                }
            }
        }
    }
    -1
}

fn main() {
    let mut src = input();
    let dst = State::new();

    // part 1
    println!("{}", bfs(src, dst, get_edges));

    // part 2
    src.rows[3] = src.rows[1];
    src.rows[1] = [3, 2, 1, 0];
    src.rows[2] = [3, 1, 0, 2];
    println!("{}", bfs(src, dst, get_edges));
}
