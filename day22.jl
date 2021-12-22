import Pkg; Pkg.add("Scanf")
using Scanf

### Part 1
N = 50
S = 2 * N + 1
grid = zeros(Bool, S, S, S)

function updateInit(v, xs)
  cut(r) = intersect(r, -N:N) .+ (N + 1)
  xl, xr, yl, yr, zl, zr = xs
  grid[cut(xl:xr), cut(yl:yr), cut(zl:zr)] .= v
end

### Part 2
concatMap(f, xs) = collect(Iterators.flatten(map(f, xs)))

# from p, remove q
function cut1D(p, q)
  q = intersect(p, q)
  if (length(q) == 0) return [p] end
  if (p == q) return [] end
  l, r = extrema(p)
  ll, rr = extrema(q)
  return filter(s -> length(s) != 0, [l:ll-1, rr+1:r])
end

# from c1, cut out c2
function cutOverlap(c1, c2)
  x1, y1, z1, v = c1
  x2, y2, z2, _ = c2
  res = []
  for xx in cut1D(x1, x2)
    push!(res, (xx, y1, z1, v))
  end
  x1 = intersect(x1, x2)
  if (length(x1) == 0) return res end
  for yy in cut1D(y1, y2)
    push!(res, (x1, yy, z1, v))
  end
  y1 = intersect(y1, y2)
  if (length(y1) == 0) return res end
  for zz in cut1D(z1, z2)
    push!(res, (x1, y1, zz, v))
  end
  return res
end

cubes = []
function update(v, xs)
  xl, xr, yl, yr, zl, zr = xs
  cur = (xl:xr, yl:yr, zl:zr, v)
  global cubes = concatMap(c -> cutOverlap(c, cur), cubes)
  push!(cubes, cur)
end

function volume(c)
  x, y, z, v = c
  return if (v) length(x) * length(y) * length(z) else 0 end
end

### Compute
for line in eachline()
  _, state, xs... = @scanf(line, "%s x=%d..%d,y=%d..%d,z=%d..%d",
                           String, Int, Int, Int, Int, Int, Int)
  updateInit(state == "on", xs)
  update(state == "on", xs)
end

println(sum(grid))
println(sum(map(volume, cubes)))
