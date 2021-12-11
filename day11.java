import java.util.Scanner;
import java.util.ArrayList;
import java.util.Arrays;

public class day11 {
  static int n, m;
  static int[][] grid;
  static int part1, part2, all_done;

  static void step() {
    for (int i = 0; i < n; i++)
      for (int j = 0; j < m; j++)
        grid[i][j]++;

    int flashed = 0;
    for (int it = 0; it < n + m; it++)
      for (int i = 0; i < n; i++)
        for (int j = 0; j < m; j++)
          if (grid[i][j] > 9) {
            flashed++;
            grid[i][j] = 0;
            for (int ii = Math.max(0, i - 1); ii <= Math.min(n - 1, i + 1); ii++)
              for (int jj = Math.max(0, j - 1); jj <= Math.min(m - 1, j + 1); jj++)
                if (grid[ii][jj] != 0)
                  grid[ii][jj]++;
          }

    part1 += flashed;
    if (all_done == 0) part2++;
    if (flashed == n * m) all_done = 1;
  }

  public static void main(String args[]) {
    Scanner s = new Scanner(System.in);
    ArrayList<String> lines = new ArrayList<String>();
    while (s.hasNext()) lines.add(s.next());
    n = lines.size();
    m = lines.get(0).length();
    grid = new int[n][m];
    for (int i = 0; i < n; i++)
      for (int j = 0; j < m; j++)
        grid[i][j] = lines.get(i).charAt(j) - '0';

    for (int it = 0; it < 100; it++) step();
    System.out.println(part1);
    while (all_done == 0) step();
    System.out.println(part2);
  }
}
