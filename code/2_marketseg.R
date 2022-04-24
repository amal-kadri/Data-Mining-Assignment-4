# market segmentation
social_marketing <- read_csv(file.path('data','social_marketing.csv'))

########################################
#preliminary data exploration: 
tweet_counts = social_marketing %>%
  select(-`...1`)%>%
  summarise_all(sum) %>% 
  t() %>%
  as.data.frame() %>%
  arrange(desc(V1)) %>%
  rename('tweet_counts'='V1')

tweet_means = social_marketing %>%
  select(-`...1`)%>%
  summarise_all(mean) %>% 
  t() %>%
  as.data.frame() %>%
  arrange(desc(V1)) %>%
  rename('mean_tweets'='V1')

beat_tweets = merge(tweet_counts,tweet_means,by=0) %>% 
  arrange(desc(tweet_counts))
  

beat_tweets %>% head(10)


#################################
#clustering
market_noID = social_marketing[,(2:37)]

#Elbow plot
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
qplot(parenting, sports_fandom, data=market_noID, color=factor(clust1$cluster))
qplot(chatter, photo_sharing, data=market_noID, color=factor(clust1$cluster))
centroids = as.data.frame(clust1[["centers"]]) %>%
  rownames_to_column('clusterID')

#Labeling Clusters
BallsNBibles = centroids %>% arrange(desc(sports_fandom)) %>% select(clusterID) %>% head(1) %>% as.numeric()


df = social_clustered[,(1:36)]

#################################
#PCA
market_PCA = prcomp(social_clustered[,(1:36)], scale=FALSE, rank=5)

market_PCA_variance_plot = plot(market_PCA)

social_PCLuster = cbind(social_clustered, market_PCA$x)

# ggplot(shows) + 
#   geom_col(aes(x=reorder(Show, PC1), y=PC1)) + 
#   coord_flip()

PCA_Scores =  market_PCA$rotation %>%
  as.data.frame() %>%
  rownames_to_column('Category')

ggplot(PCA_Scores) +
  geom_col(aes(x=reorder(Category,PC1), y=PC1)) +
  coord_flip()

ggplot(PCA_Scores) +
  geom_col(aes(x=reorder(Category,PC2), y=PC2)) +
  coord_flip()

ggplot(PCA_Scores) +
  geom_col(aes(x=reorder(Category,PC3), y=PC3)) +
  coord_flip()

ggplot(PCA_Scores) +
  geom_col(aes(x=reorder(Category,PC4), y=PC4)) +
  coord_flip()

ggplot(PCA_Scores) +
  geom_col(aes(x=reorder(Category,PC5), y=PC5)) +
  coord_flip()

cluster_counts = social_PCLuster %>%
  group_by(clusterID) %>%
  summarise(count = n(), 
            PC1 = mean(PC1), PC2 = mean(PC2), PC3 = mean(PC3), PC4 = mean(PC4), PC5 = mean(PC5))

qplot(PC3, PC2, data=cluster_counts, color=factor(clusterID))
qplot(PC3, PC4, data=cluster_counts, color=factor(clusterID)) #### investigate

#Centroid PCA
center_PCA = prcomp(centroids[,(2:37)], scale=FALSE, rank=5)
plot(center_PCA)
centers_Scored = cbind(centroids, center_PCA$x)
