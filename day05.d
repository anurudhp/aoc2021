import std.stdio;
import std.algorithm;
import std.range;
import std.typecons;

const int N = 1000;

int[N][N] grid;
void updateGrid(int[] l) {
  for (int x = min(l[0], l[2]); x <= max(l[0], l[2]); x++)
    for (int y = min(l[1], l[3]); y <= max(l[1], l[3]); y++)
      grid[x][y]++;
}
bool horz(int[] l) { return l[0] == l[2]; }
bool vert(int[] l) { return l[1] == l[3]; }

void main() {
  // input
  int[][] lines;
  {
    int x1, y1, x2, y2;
    while (readf!"%d,%d -> %d,%d\n"(x1, y1, x2, y2)) {
      if (x1 > x2) {
        swap(x1, x2);
        swap(y1, y2);
      }
      lines ~= [[x1, y1, x2, y2]];
    }
  }

  // part 1
  foreach (l; lines) {
    if (horz(l) || vert(l)) updateGrid(l);
  }
  int ans = 0;
  foreach (row; grid)
    foreach (cell; row)
      if (cell > 1) ans++;
  writeln(ans);

  // part 2
  foreach(l; lines) {
    if (l[0] + l[1] == l[2] + l[3]) {
      for (int x = l[0]; x <= l[2]; x++)
        grid[x][l[1] + l[0] - x]++;
    }
    else if (l[0] - l[1] == l[2] - l[3]) {
      for (int x = l[0]; x <= l[2]; x++)
        grid[x][l[1] - l[0] + x]++;
    }
  }
  ans = 0;
  foreach (row; grid)
    foreach (cell; row)
      if (cell > 1) ans++;
  writeln(ans);
}
