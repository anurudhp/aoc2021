% input
lines = readlines('input.txt');
n = length(lines);
m = lines(1).strlength;
grid = zeros(n, m);
for i = 1:n
    for j = 1:m
        grid(i, j) = str2num(lines(i).extract(j));
    end
end

% part 1
flow_down = grid < [10+zeros(1, m); grid(1:n-1, :)];
flow_up = grid < [grid(2:n, :); 10+zeros(1, m)];
flow_left = grid < [10+zeros(n, 1) grid(:, 1:m-1)];
flow_right = grid < [grid(:, 2:m) 10+zeros(n, 1)];

is_lowpt = flow_down .* flow_up .* flow_left .* flow_right;
part1 = sum(sum((grid + 1) .* (is_lowpt)))

% part 2
basins = zeros(n, m);
idx = 0;
for i = 1:n
    for j = 1:m
        if is_lowpt(i, j)
            idx = idx + 1;
            basins(i, j) = idx;
        end
    end
end

for it = 1:8
    flow = flow_down .* basins;
    basins = max(basins, [flow(2:n, :); zeros(1, m)]);
    flow = flow_up .* basins;
    basins = max(basins, [zeros(1, m); flow(1:n-1, :)]);
    flow = flow_left .* basins;
    basins = max(basins,  [flow(:, 2:m) zeros(n, 1)]);
    flow = flow_right .* basins;
    basins = max(basins, [zeros(n, 1) flow(:, 1:m-1)]);
end
basins = basins .* (grid < 9);

basin_sizes = arrayfun(@(ix) sum(sum(basins == ix)), 1:idx);
basin_sizes = sort(basin_sizes, "descend");
part2 = prod(basin_sizes(1:3))
