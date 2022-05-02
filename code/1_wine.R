# wine
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

plot(SSE_grid)

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

centers = as.data.frame(clust1[["centers"]])


# Best differentiation of cluster membership is total.sulfur.dioxide and free.sulfur.dioxide
q1_sulfur_plot = qplot(total.sulfur.dioxide, free.sulfur.dioxide, data=wine, color=factor(clust1$cluster), shape = color)

# wrangle for PCA
rownames(wine) <- wine$`...1`
wine_clustered = cbind(wine,clusterID) %>%
  mutate(`...1` = NULL)

#######################################################

#PCA
wine_PCA = prcomp(wine_clustered[,(1:11)], scale=FALSE, rank=2)

wine_varaince_plot = plot(wine_PCA)


wine_PCLuster = cbind(wine_clustered, wine_PCA$x)

#color plot
q1_color_plot = qplot(PC2, PC1, data=wine_PCLuster, color=color, shape=factor(clusterID))


#reds appear to have low magnitudes of PC1 and PC2 and whites appear to have high magnitudes of PC1 and PC2

#quality plot
q1_quality_plot = qplot(PC2, PC1, data=wine_PCLuster, color=factor(quality), shape=factor(clusterID))


#Due to large amount of data points, it is difficult to visualize quality alongside clusterID, but outlying points in the top left of graph show a possible range in quality of 3 to 8 for cluster 3.

PCA_Scores =  wine_PCA$rotation %>%
  as.data.frame() %>%
  rownames_to_column('Category')

q1_PC1_plot = ggplot(PCA_Scores) +
  geom_col(aes(x=reorder(Category,PC1), y=PC1)) +
  coord_flip()

q1_PC2_plot = ggplot(PCA_Scores) +
  geom_col(aes(x=reorder(Category,PC2), y=PC2)) +
  coord_flip()

q1_PC2_plot

q1_cluster_counts_table = wine_PCLuster %>%
  group_by(clusterID, color) %>%
  summarise(Count = n(), 
            PC1 = mean(PC1), 
            PC2 = mean(PC2),
            Average_Quality = mean(quality)) %>% 
  kable(caption = "Color/Quality Table")

save.image(file = file.path(path, 'output', 'tabs_figs', 'wine_tabsNfigs.RData'))

