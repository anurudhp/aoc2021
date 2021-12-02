#include <bits/stdc++.h>
using namespace std;

vector<int> compute_jumps(const string &code) {
  vector<int> jmp(code.size());
  stack<int> s;
  for (size_t i = 0; i < code.size(); i++) {
    if (code[i] == '[') {
      s.push(i);
    } else if (code[i] == ']') {
      assert(!s.empty() && "unbalanced ]");
      int j = s.top();
      s.pop();
      jmp[i] = j;
      jmp[j] = i;
    }
  }
  assert(s.empty() && "unbalanced [");
  return jmp;
}

string readfile(string name) {
  try {
    string res;
    ifstream f(name);
    for (char c; f.get(c);) {
      res.push_back(c);
    }
    return res;
  } catch (...) {
    exit(1);
  }
}

const int N = 100000;
int mem[N];

void show_state(const int p) {
  const int l = max(p - 5, 0);
  const int r = min(p + 5, N);

  cout << " ix:";
  for (int i = l; i < r; i++)
    cout << '\t' << i;
  cout << '\n';

  cout << "val:";
  for (int i = l; i < r; i++)
    cout << '\t' << mem[i];
  cout << '\n';

  cout << "";
  for (int i = l; i < r; i++)
    cout << '\t' << (i == p ? "^^^" : "   ");
  cout << '\n';

  cout << endl;
}

int main(int argc, char **argv) {
  if (argc < 3) {
    cerr << "Usage: ./bf-int <code.bf> <input.in>\n";
    return 1;
  }
  auto code = readfile(argv[1]);
  auto inp = readfile(argv[2]);
  auto jmp = compute_jumps(code);

  size_t p = 0;
  for (size_t i = 0, j = 0; i < code.size(); i++) {
    const char c = code[i];
    if (c == '>')
      p += 1;
    if (c == '<')
      p -= 1;
    if (c == '+')
      mem[p] += 1;
    if (c == '-')
      mem[p] -= 1;

    if (c == ',') {
      if (j < inp.size()) {
        mem[p] = inp[j];
        j += 1;
      } else {
        mem[p] = 0;
      }
    }
    if (c == '.') {
      cout << mem[p];
    }
    if (c == '[') {
      if (mem[p] == 0)
        i = jmp[i];
    }
    if (c == ']') {
      if (mem[p] != 0)
        i = jmp[i];
    }
    if (c == '!') {
      show_state(p);
    }
  }
  cout << endl;

  return 0;
}
