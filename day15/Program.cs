using System;
using System.Collections.Generic;

using PII = System.ValueTuple<int, int>;

class Day15 {
  static PII[] deltas = {(-1, 0), (1, 0), (0, -1), (0, 1)};
  static string[] lines;
  static int N, M;

  static int cost(int x, int y) {
    return 1 + (x/N + y/M + lines[x%N][y%M] - '1') % 9;
  }

  static int bfs(int n, int m) {
    int[,] dis = new int[n, m];
    bool[,] done = new bool[n, m];
    for (int i = 0; i < n; i++)
      for (int j = 0; j < m; j++)
        dis[i, j] = 1000000000;

    PriorityQueue<PII, int> q = new PriorityQueue<PII, int>();
    q.Enqueue((0, 0), 0);
    dis[0, 0] = 0;

    while (q.Count > 0) {
      var (x, y) = q.Dequeue();
      if (done[x, y]) continue;
      done[x, y] = true;
      foreach (var (dx, dy) in deltas) {
        int xx = x + dx, yy = y + dy;
        if (0 <= xx && xx < n && 0 <= yy && yy < m) {
          int d = dis[x, y] + cost(xx, yy);
          if (dis[xx, yy] > d) q.Enqueue((xx, yy), dis[xx, yy] = d);
        }
      }
    }
    return dis[n - 1, m - 1];
  }

  static void Main(string[] args) {
    lines = System.IO.File.ReadAllLines(args[0]);
    N = lines.GetLength(0);
    M = lines[0].Length;
    Console.WriteLine(bfs(N, M));
    Console.WriteLine(bfs(5*N, 5*M));
  }
}
