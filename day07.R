# input
inf <- commandArgs(trailingOnly=TRUE)[1]
crabs <- sapply(read.csv(inf, header=FALSE), as.integer)

# part 1
sum(abs(crabs - median(crabs)))

# part 2
d <- abs(crabs - round(mean(crabs) - 0.5))
sum((d * (d + 1)) / 2)
