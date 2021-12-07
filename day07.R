# input
inf <- commandArgs(trailingOnly=TRUE)[1]
crabs <- sapply(read.csv(inf, header=FALSE), as.integer)

# part 1
sum(abs(crabs - median(crabs)))

# part 2
xopt <- mean(crabs)
min(sapply(c(floor(xopt), ceiling(xopt)),
           function(x) { d <- abs(crabs - x); sum((d**2 + d)/2) }))

