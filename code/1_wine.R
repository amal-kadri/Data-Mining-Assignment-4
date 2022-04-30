# wine
library(resample)

wine = read.csv('data/wine.csv')

# removed single significant outlier for more accurate plot dimensions 
wine = wine %>%
  filter(free.sulfur.dioxide < 200)

#center/scale
Y = wine[,(1:11)]
Y = scale(Y, center=TRUE, scale=TRUE)

# extract the centers and scales from re-scaled data 
mu = attr(Y,"scaled:center")
sigma = attr(Y,"scaled:scale")

#Jennifer elbow plot
k_grid = seq(2,20,by=1)
SSE_grid = foreach(k = k_grid, .combine = 'c') %do% {
  cluster_k = kmeans(Y,k,nstart = 25)
  cluster_k$tot.withinss}
elbow_plot = plot(SSE_grid)

save(elbow_plot, file = "output/q1_elbow_plot")

#cluster
clust1 = kmeans(Y, 7, nstart=25)
clusterID = clust1$cluster

#cluster centers
clust1$center[1,]*sigma + mu
clust1$center[2,]*sigma + mu
clust1$center[3,]*sigma + mu
clust1$center[4,]*sigma + mu
clust1$center[5,]*sigma + mu
clust1$center[6,]*sigma + mu
clust1$center[7,]*sigma + mu
# clust1$center[8,]*sigma + mu
# clust1$center[9,]*sigma + mu
# clust1$center[10,]*sigma + mu

centers = as.data.frame(clust1[["centers"]])

# which wines are in which clusters?
which(clust1$cluster == 1)

#get vars for dim selection
colVars(as.matrix(wine[sapply(wine, is.numeric)]))

# Best differentiation of cluster membership is total.sulfur.dioxide and free.sulfur.dioxide
sulfur_plot = qplot(total.sulfur.dioxide, free.sulfur.dioxide, data=wine, color=factor(clust1$cluster), shape = color)

save(sulfur_plot, file = "output/q1_sulfur_plot")

# wrangle for PCA
rownames(wine) <- wine$`...1`
wine_clustered = cbind(wine,clusterID) %>%
  mutate(`...1` = NULL)

#######################################################

#PCA
wine_PCA = prcomp(wine_clustered[,(1:11)], scale=FALSE, rank=2)

wine_PCA_variance_plot = plot(wine_PCA)

save(wine_PCA_variance_plot, file = "output/q1_PCvariance_plot")

wine_PCLuster = cbind(wine_clustered, wine_PCA$x)

#color plot
color_plot = qplot(PC2, PC1, data=wine_PCLuster, color=color, shape=factor(clusterID))

save(color_plot, file = "output/q1_color_plot")

#reds appear to have low magnitudes of PC1 and PC2 and whites appear to have high magnitudes of PC1 and PC2

#quality plot
quality_plot = qplot(PC2, PC1, data=wine_PCLuster, color=factor(quality), shape=factor(clusterID))

save(quality_plot, file = "output/q1_quality_plot")

#Due to large amount of data points, it is difficult to visualize quality alongside clusterID, but outlying points in the top left of graph show a possible range in quality of 3 to 8 for cluster 3.

PCA_Scores =  wine_PCA$rotation %>%
  as.data.frame() %>%
  rownames_to_column('Category')

PC1_plot = ggplot(PCA_Scores) +
  geom_col(aes(x=reorder(Category,PC1), y=PC1)) +
  coord_flip()

save(PC1_plot, file = "output/q1_PC1_plot")

PC2_plot = ggplot(PCA_Scores) +
  geom_col(aes(x=reorder(Category,PC2), y=PC2)) +
  coord_flip()

save(PC2_plot, file = "output/q1_PC2_plot")

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
            avg_qual = mean(quality)) 
# %>% 
#   arrange(desc(PC1))

save(cluster_counts, file = "output/cluster_counts_table")

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

