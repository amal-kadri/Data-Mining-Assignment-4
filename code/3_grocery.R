# grocs

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



# regular
groceries_list = split(x=groceries$item, f=groceries$cartid)
groctrans = as(groceries_list, "transactions")
grocrules = apriori(groctrans, 
                    parameter=list(support=.001, confidence=.5, maxlen=10))
inspect(grocrules)
sub_milk = subset(grocrules, subset = confidence >= .8 & support >= .003)
saveAsGraph(sub_milk, file = file.path(path, 'output', 'grocrules.graphml'))

plot(grocrules)
plot(grocrules, measure = c("support", "lift"), shading = "confidence")
plot(grocrules, method='two-key plot')
plot(head(sub1, 100, by='lift'), method='graph')

# labeling carts that don't have milk in them to study these
groceries_milktag <- groceries %>% 
  filter(item == "whole milk") %>% 
  merge(groceries, by = "cartid", all = TRUE, suffix = c("", ".x")) %>% 
  mutate(item = ifelse(is.na(item) == T, "no milk", item)) %>% 
  filter(item == "no milk") %>% 
  select(- item.x) %>% 
  unique.array() %>% 
  rbind(groceries) %>% 
  arrange(cartid)

milktag_list <- split(x=groceries_milktag$item, f=groceries_milktag$cartid)
milktrans = as(milktag_list, "transactions")
milkrules = apriori(milktrans, 
                    parameter=list(support=.003, confidence=.85, maxlen=10))
inspect(milkrules)
milk_tag = subset(milkrules)
saveAsGraph(milk_tag, file = file.path(path, 'output', 'milkrules.graphml'))

# no milk filtering out milk, perhaps we don't need this
groceries_nomilk <- groceries %>% 
  filter(item != "whole milk" & 
           item != "other vegetables" &
           item != "yogurt")
groceries_nomilk_list  = split(x=groceries_nomilk$item, f=groceries_nomilk$cartid)
groctrans_nomilk = as(groceries_nomilk_list, "transactions")
grocrules_nomilk = apriori(groctrans_nomilk, 
                    parameter=list(support=.003, confidence=.5, maxlen=10))
inspect(grocrules_nomilk)
sub_nomilk <- subset(grocrules_nomilk)
saveAsGraph(sub_nomilk, file = file.path(path, 'output', 'grocrules_nomilk.graphml'))





# Then use the data on grocery purchases in groceries.txt and find some interesting association rules for these shopping baskets. 

# Pick your own thresholds for lift and confidence; just be clear what these thresholds are and how you picked them. 
# Do your discovered item sets make sense? 
# Present your discoveries in an interesting and concise way.

# groceries_tags <- groceries %>% 
#   group_by(item) %>% 
#   summarise(count = length(item), .groups = 'drop') %>%
#   arrange(desc(count)) %>% 
#   mutate(tag = case_when(item == "pork" | 
#                            item == "chicken" | 
#                            item == "beef" |
#                            item == "sausage" |
#                            item ==  "frankfurter" |
#                            item == "hamburger meat" |
#                            item == "meat spreads" |
#                            item == "liver loaf" |
#                            item == "turkey" |
#                            item == "meat" |
#                            item == "ham" ~ "meat", 
#                          item == "whole milk" |
#                            item == "yogurt" |
#                            item == "whipped/sour cream" |
#                            item == "curd" |
#                            item == "butter" |
#                            item == "cream cheese " |
#                            item == "UHT-milt" |
#                            item == "butter milk"  |
#                            item == "cream" |
#                            item == "curd cheese" |
#                            item == "specialty cheese" |
#                            item == "condensed milk" |
#                            item == "spread cheese" |
#                            item == "processed cheese" |
#                            item == "soft cheese" |
#                            item == "ice cream" |
#                            item == "sliced cheese" |
#                            item == "hard cheese" ~ "dairy"))

# # plot all the rules in (support, confidence) space
# # notice that high lift rules tend to have low support
# plot(grocrules)
# 
# # can swap the axes and color scales
# plot(grocrules, measure = c("support", "lift"), shading = "confidence")
# 
# # "two key" plot: coloring is by size (order) of item set
# plot(grocrules, method='two-key plot')
# 

