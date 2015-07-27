args <- commandArgs(trailingOnly = TRUE)

# Compute the distance matrix using Levenshtein's distance
distance_matrix<-read.table(args[1],sep="\t")

# Clustering
clustering<-hclust(as.dist(distance_matrix),method="average")

# Output
pdf(args[2])
plot(clustering,hang= -1)
dev.off()
