public def dfs(u, e)
  return 1 if u == "end"
  return 0 if u == "start" && $vis[u] > 0
  if /[[:lower:]]+/.match?(u)
    return 0 if $vis[u] >= 1 + e
    e -= 1 if $vis[u] > 0
  end
  $vis[u] += 1
  res = $adj[u].map{|v| dfs(v, e)}.sum
  $vis[u] -= 1
  return res
end

def main()
  $adj = Hash.new
  $vis = Hash.new
  while (line = gets) != nil
    a, b = line.strip.split("-")
      .each{|u|
        if not $adj.has_key?(u)
          $adj[u] = Array.new
          $vis[u] = 0
        end
      }
    $adj[a].push(b)
    $adj[b].push(a)
  end

  puts [0, 1].map{|e| dfs("start", e)}
end

main()
