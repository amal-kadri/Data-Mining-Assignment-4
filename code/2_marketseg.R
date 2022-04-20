# market segmentation
social_marketing <- read_csv(file.path('data','social_marketing.csv'))

#preliminary data exploration: clustering
market_noID = social_marketing[,(2:37)]

##Elbow plot
k_grid = seq(2,20,by=1)
SSE_grid = foreach(k = k_grid, .combine = 'c') %do% {
  cluster_k = kmeans(market_noID,k,nstart = 25)
  cluster_k$tot.withinss
}
plot(SSE_grid) #seems to bend around 6

clust1 = kmeans(market_noID, 10, nstart = 25) #chose 10 after some trial and error
clust1$center %>% round(1)  # not super helpful, location in a 9 dimensional feature space
clusterID = clust1$cluster

social_marketing = cbind(social_marketing,clusterID)

# A few plots with cluster membership shown
# qplot is in the ggplot2 library
qplot(current_events, sports_fandom, data=market_noID, color=factor(clust1$cluster))
qplot(religion, sports_fandom, data=market_noID, color=factor(clust1$cluster))
qplot(religion, sports_fandom, data=market_noID, color=factor(clust1$cluster))
centroids = as.data.frame(clust1[["centers"]])
