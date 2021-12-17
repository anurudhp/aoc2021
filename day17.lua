-- target area: x=20..30, y=-10..-5
xl, xr, yl, yh = io.read():match("target area: x=(%-?%d+)..(%-?%d+), y=(%-?%d+)..(%-?%d+)")
xl, xr, yl, yh = tonumber(xl), tonumber(xr), tonumber(yl), tonumber(yh)
if xr < 0 then
  xl = -xl
  xr = -xr
end
if xl <= 0 then
  print("inf")
  os.exit()
end

function compute()
  yy = 0
  count = 0
  for vyi=150,-200,-1 do
    for vxi=1,500 do
      vx, vy = vxi, vyi
      x, y = 0, 0
      while y >= yl do
        x = x + vx
        y = y + vy
        if xl <= x and x <= xr and yl <= y and y <= yh then
          if yy == 0 then yy = vyi end
          count = count + 1
          break
        end
        if vx > 0 then vx = vx - 1 end
        vy = vy - 1
      end
    end
  end
  return yy, count
end

yy, count = compute()
ans = (yy * (yy + 1))//2
print(ans, count)
