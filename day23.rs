use std::collections::BinaryHeap;
use std::collections::HashMap;
use std::io;
use std::mem;

// #############
// #...........#
// ###B#C#B#D###
//   #A#D#C#A#
//   #########

fn vec_to_st(v: &Vec<Vec<usize>>) -> usize {
    let mut st = 0;
    for i in (0..4).rev() {
        let lo = v[i][0].min(v[i][1]);
        let hi = v[i][0].max(v[i][1]);
        st = (st << 8) | (hi << 4) | lo
    }
    st
}

fn input() -> usize {
    let mut pos: Vec<Vec<usize>> = vec![vec![]; 4];
    for i in 0..4 {
        let mut buf = String::new();
        io::stdin().read_line(&mut buf).expect("");
        if i < 2 {
            continue;
        }
        let buf: Vec<char> = buf.chars().collect();
        for j in [3, 5, 7, 9] {
            if let Some(d) = buf[j].to_digit(16) {
                let m = i + j - 5;
                let v = &mut pos[(d - 10) as usize];
                v.push(m);
            }
        }
    }
    vec_to_st(&pos)
}

fn jump(i: usize, j: usize) -> i32 {
    assert!(i < 8);
    assert!(j >= 8 && j < 15);
    let p = 10 + i / 2;
    let b = if j == 8 || j == 14 { 1 } else { 0 };
    ((i & 1) + 2 * (if j >= p { j - p + 1 } else { p - j }) - b) as i32
}

fn show_grid(st: usize) {
    let show_c = |c| match c {
        0 => print!("A"),
        1 => print!("B"),
        2 => print!("C"),
        3 => print!("D"),
        4 => print!("."),
        100 => print!("*"),
        _ => print!("|"),
    };
    let mut pos = vec![vec![0, 0]; 4];
    let mut at = vec![4; 16];
    for i in 0..8 {
        let ix = (st >> (4 * i)) & 0xF;
        pos[i / 2][i & 1] = ix;
        at[ix] = i / 2;
    }

    println!("_______________");
    for i in 8..15 {
        if 10 <= i && i <= 13 {
            show_c(4)
        }
        show_c(at[i]);
    }
    println!();
    for d in 0..2 {
        print!(" ");
        for i in 0..4 {
            show_c(5);
            show_c(at[2 * i + d]);
        }
        show_c(5);
        println!();
    }
    println!("_______________");
    println!();
}

fn main() {
    // for i in 0..8 {
    //     for j in 8..15 {
    //         println!(">> D({}, {}) = {}", i, j, jump(i, j));
    //     }
    // }
    // return;
    let init = input();
    let targ: usize = 0x76543210;
    let cost: Vec<i32> = vec![1, 10, 100, 1000];
    let free = 4;

    let mut heap = BinaryHeap::new();
    let mut dis = HashMap::new();
    let mut par = HashMap::new();

    heap.push((0, init));
    dis.insert(init, 0);

    while !heap.is_empty() {
        if let Some((du, u)) = heap.pop() {
            if u == targ {
                break;
            }
            let du = -du;
            if let Some(dd) = dis.get(&u) {
                if du != *dd {
                    continue;
                }
                let mut pos = vec![vec![0, 0]; 4];
                let mut at = vec![free; 16];
                for i in 0..8 {
                    let ix = (u >> (4 * i)) & 0xF;
                    pos[i / 2][i & 1] = ix;
                    at[ix] = i / 2;
                }
                let mut edges = Vec::new();

                for i in 0..4 {
                    for j in 0..2 {
                        let p = pos[i][j];
                        // room
                        if p < 8 {
                            if p % 2 == 1 && at[p - 1] != free {
                                continue;
                            }
                            let c = (10 + p / 2) as usize;
                            for k in c..15 {
                                if at[k] != free {
                                    break;
                                }
                                let t = pos[i][j];
                                pos[i][j] = k;
                                edges.push((vec_to_st(&pos), jump(t, k) * cost[i]));
                                pos[i][j] = t;
                            }
                            for k in (8..c).rev() {
                                if at[k] != free {
                                    break;
                                }
                                let t = pos[i][j];
                                pos[i][j] = k;
                                edges.push((vec_to_st(&pos), jump(t, k) * cost[i]));
                                pos[i][j] = t;
                            }
                        } else {
                            // hallway
                            if at[2 * i + 1] != free && (at[2 * i] != free || at[2 * i + 1] != i) {
                                continue;
                            }
                            let mut hall = if p >= 10 + i { 10 + i..p } else { p..9 + i };
                            if hall.all(|k| at[k] == free) {
                                let k = if at[2 * i + 1] == free {
                                    2 * i + 1
                                } else {
                                    2 * i
                                };
                                let t = pos[i][j];
                                pos[i][j] = k;
                                edges.push((vec_to_st(&pos), jump(k, t) * cost[i]));
                                pos[i][j] = t;
                            }
                        }
                    }
                }

                for (v, w) in edges {
                    if match dis.get(&v) {
                        Some(dv) => *dv > du + w,
                        None => true,
                    } {
                        dis.insert(v, du + w);
                        par.insert(v, u);
                        heap.push((-du - w, v));
                    }
                }
            }
        }
    }

    if let Some(d) = dis.get(&targ) {
        println!("{}", d);
    }

    let mut path = Vec::new();
    let mut cur = targ;
    while cur != init {
        path.push(cur);
        if let Some(cc) = par.get(&cur) {
            cur = *cc;
        } else {
            break;
        };
    }
    path.push(init);
    path.reverse();
    for i in path {
        show_grid(i);
    }

    println!("total: {}", dis.len());
}
