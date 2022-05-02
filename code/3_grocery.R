# grocs
grocs <- read.delim(file.path(path, 'data', 'groceries.txt'), header = FALSE)

# splits cart string into a unique obs for each item identified by "cartid"
obs <- length(grocs$V1)
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


# REGULAR
# make them into a list for apriori
groceries_list = split(x=groceries$item, f=groceries$cartid)
groctrans = as(groceries_list, "transactions")

# parameterize the rule search
grocrules = apriori(groctrans, 
                    parameter=list(support=.0012, confidence=.8, maxlen=10))

# save grocrules as graph AND as .RDs
saveAsGraph(grocrules, file = file.path(path, 'output', 'grocrules.graphml'))

# inspect the rules in a table 
grocrules_df <- arules::DATAFRAME(grocrules)

# output some tables and figures
# lift table
high_lift <- grocrules_df %>% 
  arrange(desc(lift)) %>% 
  slice_head(n = 10) %>% 
  kable(caption = "High Lift Rules")

# conf table
high_conf <- grocrules_df %>% 
  arrange(desc(support)) %>% 
  slice_head(n = 10) %>%
    arrange(desc(confidence))
  kable(caption = "High Confidence Rules")

# repeat these commands in the rmd since they 
conf_sup <- plot(grocrules, jitter = .3)
lift_sup <- plot(grocrules, measure = c("support", "lift"), shading = "confidence", jitter = .3)
twokey <- plot(grocrules, method='two-key plot', jitter = .3)


# NO MILK
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

# list
milktag_list <- split(x=groceries_milktag$item, f=groceries_milktag$cartid)
milktrans = as(milktag_list, "transactions")

# specification
milkrules = apriori(milktrans, 
                    parameter=list(support=.0012, confidence=.85, maxlen=10))
saveAsGraph(milkrules, file = file.path(path, 'output', 'milkrules.graphml'))

# inspect rules
milkrules_df <- arules::DATAFRAME(milkrules)

# some tables and figures
nomilk_tab <- milkrules_df %>% 
  filter(RHS == "{no milk}") %>% 
  arrange(desc(lift)) %>% 
  slice_head(n = 10) %>% 
  kable(caption = "High Lift Rules: No-Milk Carts")

milk_tab <- milkrules_df %>% 
  filter(RHS == "{whole milk}") %>% 
  arrange(desc(lift)) %>% 
  slice_head(n = 10) %>% 
  kable(caption = "High Lift Rules: Whole Milk Carts")

# save table and figures output to be loaded onto .rmd 
save(file = file.path(path, 'output', 'tabs_figs', 'arules_tabsNfigs.RData'), list = c('high_lift', 'high_conf', 'conf_sup', 'lift_sup', 'twokey', 'nomilk_tab', 'milk_tab'))

# Then use the data on grocery purchases in groceries.txt and find some interesting association rules for these shopping baskets. 

# Pick your own thresholds for lift and confidence; just be clear what these thresholds are and how you picked them. 
# Do your discovered item sets make sense? 
# Present your discoveries in an interesting and concise way.