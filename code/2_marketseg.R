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
elbow_plot = plot(SSE_grid) #seems to bend around 6, chose 10

clust1 = kmeans(market_noID, 10, nstart = 25) #chose 10 after some trial and error
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
BallsNBibles = centroids %>% arrange(desc(sports_fandom)) %>% select(clusterID) %>% head(1) %>% as.numeric() #sports fandom, religion, parenting
CollegeGamers = centroids %>% arrange(desc(online_gaming)) %>% select(clusterID) %>% head(1) %>% as.numeric() #gaming, college, sports playing
JustChatting = centroids %>% arrange(desc(chatter)) %>% select(clusterID) %>% head(1) %>% as.numeric() #chatter, photo sharing, shopping
CrossFitKids = centroids %>% arrange(desc(health_nutrition)) %>% select(clusterID) %>% head(1) %>% as.numeric()

#################################
#PCA
market_PCA = prcomp(social_clustered[,(1:36)], scale=FALSE, rank=5)

market_PCA_variance_plot = plot(market_PCA)

social_PCLuster = cbind(social_clustered, market_PCA$x)

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
#corrplot
correplation_plot = ggcorrplot::ggcorrplot(cor(market_noID))

qplot(PC3, PC2, data=cluster_counts, color=factor(clusterID))
qplot(PC3, PC4, data=cluster_counts, color=factor(clusterID)) #### investigate

#Centroid PCA
center_PCA = prcomp(centroids[,(2:37)], scale=FALSE, rank=5)
plot(center_PCA)
centers_Scored = cbind(centroids, center_PCA$x)

######################
#final graphs
grid_arrange_shared_legend <- #function that makes better ggplot grids
  function(...,
           ncol = length(list(...)),
           nrow = 1,
           position = c("bottom", "right")) {
    
    plots <- list(...)
    position <- match.arg(position)
    g <-
      ggplotGrob(plots[[1]] + theme(legend.position = position))$grobs
    legend <- g[[which(sapply(g, function(x)
      x$name) == "guide-box")]]
    lheight <- sum(legend$height)
    lwidth <- sum(legend$width)
    gl <- lapply(plots, function(x)
      x + theme(legend.position = "none"))
    gl <- c(gl, ncol = ncol, nrow = nrow)
    
    combined <- switch(
      position,
      "bottom" = arrangeGrob(
        do.call(arrangeGrob, gl),
        legend,
        ncol = 1,
        heights = unit.c(unit(1, "npc") - lheight, lheight)
      ),
      "right" = arrangeGrob(
        do.call(arrangeGrob, gl),
        legend,
        ncol = 2,
        widths = unit.c(unit(1, "npc") - lwidth, lwidth)
      )
    )
    
    grid.newpage()
    grid.draw(combined)
    
    # return gtable invisibly
    invisible(combined)
    
  }
sportsdads_parents = ggplot(centroids) +
  geom_point(aes(x=sports_fandom,y=parenting, color=factor(clusterID),
                 shape=factor(clusterID==BallsNBibles),
                 size = factor(clusterID==BallsNBibles)))
sportsdads_religion = ggplot(centroids) +
  geom_point(aes(x=sports_fandom,y=religion, color=factor(clusterID), 
                 shape=factor(clusterID==BallsNBibles),
                 size = factor(clusterID==BallsNBibles)))
sportsdads_chatter = ggplot(centroids) +
  geom_point(aes(x=sports_fandom,y=chatter, color=factor(clusterID),
                 shape=factor(clusterID==BallsNBibles),
                 size = factor(clusterID==BallsNBibles)))
BallsNBibles_graph = grid_arrange_shared_legend(sportsdads_religion,sportsdads_parents,sportsdads_chatter)


healthnuts_fitness = ggplot(centroids) +
  geom_point(aes(x=health_nutrition,y=personal_fitness, color=factor(clusterID),
                 shape = factor(clusterID==CrossFitKids),
                 size =factor(clusterID==CrossFitKids)))
healthnuts_chatter = ggplot(centroids) +
  geom_point(aes(x=health_nutrition,y=chatter, color=factor(clusterID),
                 shape = factor(clusterID==CrossFitKids),
                 size = factor(clusterID==CrossFitKids)))
CrossFitKids_graph = grid_arrange_shared_legend(healthnuts_fitness,healthnuts_chatter)

chatters_photos = ggplot(centroids) +
  geom_point(aes(x=chatter,y=photo_sharing, color=factor(clusterID),
                 shape = factor(clusterID==JustChatting),
                 size = factor(clusterID==JustChatting)))
chatters_current = ggplot(centroids) +
  geom_point(aes(x=chatter,y=current_events, color=factor(clusterID),
                 shape = factor(clusterID==JustChatting),
                 size = factor(clusterID==JustChatting)))
chatters_shopping = ggplot(centroids) +
  geom_point(aes(x=chatter,y=shopping, color=factor(clusterID),
                 shape = factor(clusterID==JustChatting),
                 size = factor(clusterID==JustChatting)))
JustChatting_graph =  grid_arrange_shared_legend(chatters_current, chatters_photos, chatters_shopping)

gamers_college = ggplot(centroids) +
  geom_point(aes(x=online_gaming,y=college_uni, color=factor(clusterID),
                 shape = factor(clusterID==CollegeGamers),
                 size = factor(clusterID==CollegeGamers)))
gamers_sports = ggplot(centroids) +
  geom_point(aes(x=online_gaming,y=sports_playing, color=factor(clusterID),
                 shape = factor(clusterID==CollegeGamers),
                 size = factor(clusterID==CollegeGamers)))
gamers_chatter = ggplot(centroids) +
  geom_point(aes(x=online_gaming,y=chatter, color=factor(clusterID),
                 shape = factor(clusterID==CollegeGamers),
                 size = factor(clusterID==CollegeGamers)))
CollegeGamers_graph = grid_arrange_shared_legend(gamers_college,gamers_sports,gamers_chatter)  

save.image(file = file.path(path, 'output', 'tabs_figs', '2_marketseg_tabsNfigs.RData'))

  
  