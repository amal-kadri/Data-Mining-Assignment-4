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

rownames(social_marketing) <- social_marketing$`...1`
social_clustered = cbind(social_marketing,clusterID) %>%
  mutate(`...1` = NULL)



# A few plots with cluster membership shown
# qplot is in the ggplot2 library
qplot(current_events, sports_fandom, data=market_noID, color=factor(clust1$cluster))
qplot(religion, sports_fandom, data=market_noID, color=factor(clust1$cluster))
qplot(religion, sports_fandom, data=market_noID, color=factor(clust1$cluster))
centroids = as.data.frame(clust1[["centers"]])
df = social_clustered[,(1:36)]


market_PCA = prcomp(social_clustered[,(1:36)], scale=FALSE, rank=10)
round(market_PCA$rotation[,1:10],2)
plot(market_PCA)
df = as.data.frame(round(market_PCA$rotation[,1:10],2))

# shows = merge(shows, PCApilot$x[,1:3], by="row.names")
# shows = rename(shows, Show = Row.names)

categorized_data = social_marketing %>%
  select(-`...1`)
categorized_data =  as.data.frame(t(categorized_data))
market_PCA2 = prcomp(categorized_data[,(1:36)], scale=FALSE, rank=5)
round(market_PCA2$rotation[,1:5],2)
  
  group_by(Show) %>% 
  select(-Viewer) %>%
  summarize_all(mean) %>%
  column_to_rownames(var="Show") 
  



