# wine
library(resample)

wine = read.csv('data/wine.csv')

#center/scale
Y = wine[,(1:11)]
Y = scale(Y, center=TRUE, scale=TRUE)

# extract the centers and scales from rescaled data 
mu = attr(Y,"scaled:center")
sigma = attr(Y,"scaled:scale")

#cluster
clust1 = kmeans(Y, 2, nstart=25)

#cluster centers
clust1$center[1,]*sigma + mu
clust1$center[2,]*sigma + mu

as.data.frame(clust1[["centers"]])

# which wines are in which clusters?
which(clust1$cluster == 1)
which(clust1$cluster == 2)
# which(clust1$cluster == 3)
# which(clust1$cluster == 4)

wine = as.data.frame(wine)

sapply(wine, function(x) colVars())
colVars(as.matrix(wine[sapply(wine, is.numeric)]))

# A few plots with cluster membership shown
# qplot is in the ggplot2 library
qplot(total.sulfur.dioxide, volatile.acidity, data=wine, color=factor(clust1$cluster))
qplot(alcohol, residual.sugar, data=wine, color=factor(clust1$cluster))
