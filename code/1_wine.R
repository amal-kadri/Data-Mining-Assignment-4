# wine
library(resample)

wine = read.csv('data/wine.csv')

wine = wine %>%
  filter(free.sulfur.dioxide < 200)

#center/scale
Y = wine[,(1:11)]
Y = scale(Y, center=TRUE, scale=TRUE)

# extract the centers and scales from rescaled data 
mu = attr(Y,"scaled:center")
sigma = attr(Y,"scaled:scale")

#cluster
clust1 = kmeans(Y, 6, nstart=25)
clusterID = clust1$cluster

#cluster centers
clust1$center[1,]*sigma + mu
clust1$center[2,]*sigma + mu
clust1$center[3,]*sigma + mu
clust1$center[4,]*sigma + mu
clust1$center[5,]*sigma + mu
clust1$center[6,]*sigma + mu
clust1$center[7,]*sigma + mu
clust1$center[8,]*sigma + mu
clust1$center[9,]*sigma + mu
clust1$center[10,]*sigma + mu

centers = as.data.frame(clust1[["centers"]])

# which wines are in which clusters?
# which(clust1$cluster == 1)

#get vars for dim selection
colVars(as.matrix(wine[sapply(wine, is.numeric)]))

# A few plots with cluster membership shown
# qplot is in the ggplot2 library
# qplot(fixed.acidity, residual.sugar, data=wine, color=factor(clust1$cluster), shape = color)
# 
# qplot(fixed.acidity, chlorides, data=wine, color=factor(clust1$cluster), shape = color)

qplot(total.sulfur.dioxide, free.sulfur.dioxide, data=wine, color=factor(clust1$cluster), shape = color)

# qplot(pH, alcohol, data=wine, color=factor(clust1$cluster), shape = color)
#xlim = c(NA, NA), ylim = c(NA, NA),) 

#Jennifer elbow plot
k_grid = seq(2,20,by=1)
SSE_grid = foreach(k = k_grid, .combine = 'c') %do% {
  cluster_k = kmeans(Y,k,nstart = 25)
  cluster_k$tot.withinss}
plot(SSE_grid)

# wrangle for PCA
rownames(wine) <- wine$`...1`
wine_clustered = cbind(wine,clusterID) %>%
  mutate(`...1` = NULL)

#######################################################

#PCA
wine_PCA = prcomp(wine_clustered[,(1:11)], scale=FALSE, rank=2)

wine_PCA_variance_plot = plot(wine_PCA)

wine_PCLuster = cbind(wine_clustered, wine_PCA$x)

#color plot
qplot(PC2, PC1, data=wine_PCLuster, color=factor(wine_PCLuster$cluster), shape = color)

#color 

#reds appear to have low magnitudes of PC1 and PC2 and whites appear to have high magnitudes of PC1 and PC2

#quality plot
qplot(PC2, PC1, data=wine_PCLuster, color=factor(wine_PCLuster$quality), shape = color)


PCA_Scores =  wine_PCA$rotation %>%
  as.data.frame() %>%
  rownames_to_column('Category')

ggplot(PCA_Scores) +
  geom_col(aes(x=reorder(Category,PC1), y=PC1)) +
  coord_flip()

ggplot(PCA_Scores) +
  geom_col(aes(x=reorder(Category,PC2), y=PC2)) +
  coord_flip()

# ggplot(PCA_Scores) +
#   geom_col(aes(x=reorder(Category,PC3), y=PC3)) +
#   coord_flip()
# 
# ggplot(PCA_Scores) +
#   geom_col(aes(x=reorder(Category,PC4), y=PC4)) +
#   coord_flip()
# 
# ggplot(PCA_Scores) +
#   geom_col(aes(x=reorder(Category,PC5), y=PC5)) +
#   coord_flip()

cluster_counts = wine_PCLuster %>%
  group_by(clusterID, color) %>%
  summarise(count = n(), 
            PC1 = mean(PC1), 
            PC2 = mean(PC2),
            avg_qual = mean(quality)) %>% 
  arrange(desc(PC1))

########################################

#hierarchical clustering?

wine_dist = dist(wine_PCLuster)

h2 = hclust(wine_dist, method='complete')
c2 = cutree(h2, 2)
D2 = data.frame(wine_PCLuster, z = c2)
ggplot(D2) + geom_point(aes(x=PC1, y=PC2, col=factor(z), shape=color))
ggplot(D2) + geom_point(aes(x=PC1, y=PC2, col=color, shape=factor(z)))


#################

# save/file put in output as .RData

# save/image the rm()

# .rds for local quick loading data structure

