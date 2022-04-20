# grocs

library(tidyverse)
library(foreach)
library(arules)
library(arulesViz)

grocs <- read.delim(file.path(path, 'data', 'groceries.txt'), header = FALSE)

# splits cart string into a unique obs for each item identified by "cartid"
obs <- row_number(grocs)
groceries <- foreach(i = 1:obs, .combine = rbind) %do% {
  
  split <- grocs$V1[i] %>% 
    str_split(pattern = ",") %>% 
    as.data.frame() %>% 
    mutate(cartid = i) %>% 
    as.data.frame()
  
  colnames(split) <- c("item", "cartid")
  
  split
}

groceries$cartid = factor(groceries$cartid)

groceries_list = split(x=groceries$item, f=groceries$cartid)

## Remove duplicates ("de-dupe")
# lapply says "apply a function to every element in a list"
# unique says "extract the unique elements" (i.e. remove duplicates)

## Cast this resulting list of playlists as a special arules "transactions" class.
groctrans = as(groceries_list, "transactions")
summary(groctrans)

# Now run the 'apriori' algorithm
# Look at rules with support > .01 & confidence >.1 & length (# artists) <= 5
grocrules = apriori(groctrans, 
                     parameter=list(support=.01, confidence=.1, maxlen=2))



# Look at the output... so many rules!
inspect(grocrules)

## Choose a subset
inspect(subset(grocrules, lift > 3))
inspect(subset(grocrules, confidence > 0.6))
inspect(subset(grocrules, lift > 3 & confidence > 0.05))

# plot all the rules in (support, confidence) space
# notice that high lift rules tend to have low support
plot(grocrules)

# can swap the axes and color scales
plot(grocrules, measure = c("support", "lift"), shading = "confidence")

# "two key" plot: coloring is by size (order) of item set
plot(grocrules, method='two-key plot')

# can now look at subsets driven by the plot
inspect(subset(grocrules, support > 0.035))
inspect(subset(grocrules, confidence > 0.6))


# graph-based visualization
sub1 = subset(grocrules, subset=confidence > 0.01 & support > 0.005)
summary(sub1)
plot(sub1, method='graph')
?plot.rules

plot(head(sub1, 100, by='lift'), method='graph')

# Then use the data on grocery purchases in groceries.txt and find some interesting association rules for these shopping baskets. 

# Pick your own thresholds for lift and confidence; just be clear what these thresholds are and how you picked them. 
# Do your discovered item sets make sense? 
# Present your discoveries in an interesting and concise way.
