# input
inf <- commandArgs(trailingOnly=TRUE)[1]
X <- sapply(read.csv(inf, header=FALSE), as.integer)

# part 1
sum(abs(X - median(X)))

# part 2
N <- length(X)
min(sapply(unique(round(mean(X) + 0.5 - seq(1, N)/N)),
           function(y) { sum((X - y)^2 + abs(X - y)) / 2 }))
