#install.packages("plotly")
#install.packages("moments")

library(lubridate)
library(data.table) #convert seconds to days
library(plotly) #interactive plots
library(moments) #to get skewness
library(factoextra) #to visualize clusters
library(plyr)
library(svMisc)

getwd()
setwd("C:/Users/pares/OneDrive/Documents/assessments/online retail")

data <- read.csv("OnlineRetail.csv",stringsAsFactors = FALSE)
str(data)

#Converting invoice date to date type
data$InvoiceDate <- strptime(data$InvoiceDate, format = "%m/%d/%Y %H:%M")

summary(data)

#A lot of customer IDs are missing -- as we cant segment non existing customers -- lets remove them from dataset
data <- na.omit(data) 

#There are negative values in quantity!

sum(data$Quantity < 0) #8,905 entries have negative values of quantity 

head(data[data$Quantity < 0,]) #A brief glance shows, it could be the cancelled items(InvoiceNo starts with "C")! --- customer is returning the item!

#Creating a column that separates the purchased items vs the returned items!
data$purchased_item <- ifelse(grepl("C",data$InvoiceNo, fixed = TRUE) == TRUE, 0,1) 

#Since dataset varies over different locations, lets limit it!

sort(table(data$Country)) #UK has the most entires -- lets consider only UK as, customers have different preferences over different geographical regions!

data <- subset(data,data$Country == "United Kingdom")

#-----------------------LETS RFM-------------------------

#Calculate 3 different scores for each customer
#1. RECENCY -- How recently has the customer made his/her purchase?
#2. FREQUENCY -- How frequent is the customer? How many purchases over the given time frame?
#3. MONETARY VALUE -- How much amount does each customer bring in?

customers <- as.data.frame(unique(data$CustomerID))
colnames(customers) <- "CustomerID"

#------------RECENCY--------------------

data$recency <- max(data$InvoiceDate) - data$InvoiceDate #Now this is in seconds, lets convert it in number of days...

data$recency <- seconds_to_period(data$recency)
data$recency <- data$recency@day + data$recency@hour/24 + data$recency@minute/(24*60) + data$recency@.Data/(24*60*60)

temp <- subset(data, data$purchased_item == 1)

recency <- aggregate(recency ~ CustomerID, data = data, FUN = mean, na.rm = TRUE)

customers <- merge(customers, recency, all = TRUE)

remove(recency)
remove(temp)


#------------FREQUENCY------------------

uniqueN(data$InvoiceNo) #19,857 number of unique invoices for 3950 customers!

freq <- aggregate(InvoiceNo ~ CustomerID, data = data, FUN = uniqueN)
customers <- merge(customers,freq, all = TRUE, by = "CustomerID")
colnames(customers)[3]  <- "Frequency"

remove(freq)


#----------MONETARY VALUE---------------

data$revenue <- data$Quantity * data$UnitPrice

revenue <- aggregate(revenue ~ CustomerID, data = data, FUN = sum)
customers <- merge(customers,revenue, all = TRUE)

remove(revenue)

summary(customers)#there are negative values of revenue -- probably customers who purchased something before the time frame given, but
#returned it in the given timeframe! Setting these values to zero!

customers$revenue[customers$revenue < 0] <- 0

str(customers)


#----------------PRE-PROCESSING DATA FOR K-MEANS---------------------

#1. kmeans is very sensitive to outliers
#2. We should always scale and normalize data for kmeans

#-----------Pareto Analysis(80/20 rule)------------

#Pareto Analysis -- The rule says that more or less, 80% of the results come from the 20% of the causes! In this context, 80% of sales are caused 
#by 20% of the customers. Meaning, top 20% customers contribute most to the sales -- these are our high value customers!
pareto_cutoff <- 0.8*sum(customers$revenue)

customers <- customers[order(customers$revenue, decreasing = TRUE),]

customers$pareto <- ifelse(cumsum(customers$revenue) <= pareto_cutoff,"Top 20%","Bottom 80%") 
customers$pareto <- as.factor(customers$pareto)

round(prop.table(table(customers$pareto)),2) #Close to 72/28 rule, but close enough!

str(customers)

customers <- customers[order(customers$revenue),]

# Lets look at it visually!

p1 <- ggplot(data = customers) +
  geom_point(aes(x = Frequency,y = revenue, color = recency, shape = pareto)) + ggtitle("Original Values") + scale_shape_manual(name = "80/20 rule",values = c(1,2))

ggplotly(p1)

#------How skewed is out data?---------
  
#We need to tranform the data (scale and normalize it!)

ggplot(data = customers, aes(x = recency)) +
  geom_histogram()

ggplot(data = customers, aes(x = Frequency)) +
  geom_histogram()

ggplot(data = customers, aes(x = revenue)) +
  geom_histogram()

#All the variables are positively skewed! Lets take log tranform of each!

skewness(customers$recency)
skewness(customers$Frequency)
skewness(customers$revenue)


customers$log_recency <- log(customers$recency)
customers$log_frequency <- log(customers$Frequency)

customers$revenue <- customers$revenue + 0.01 #Since, there are 0 values, we dont wanna take log(0)
customers$log_revenue <- log(customers$revenue)


#Lets scale the data using Z- scores!

customers$z_recency <-  scale(customers$log_recency, scale = TRUE, center = TRUE)
customers$z_frequency <-  scale(customers$log_frequency, scale = TRUE, center = TRUE)
customers$z_revenue <- scale(customers$log_revenue, scale = TRUE, center = TRUE)

#Lets visualize the log transformed and scaled variables!

p2 <- ggplot(data = customers) +
  geom_point(aes(x = log_frequency,y = log_revenue, color = log_recency, shape = pareto)) + ggtitle("Log Tranformed values") + scale_shape_manual(name = "80/20 rule",values = c(1,2))

ggplotly(p2)


p3 <- ggplot(data = customers) +
  geom_point(aes(x = z_frequency,y = z_revenue, color = z_recency, shape = pareto)) + ggtitle("Scaled Values") + scale_shape_manual(name = "80/20 rule",values = c(1,2))

ggplotly(p3)

#Both of these plots are almost similar- but now we can better analyze the data -- Outliers are better visible!

#Top Right Corner -- has quite a few outliers -- these are our high frequency; high revenue; and fairly recent customers --
#Bottom Left Corner -- these are outliers too -- with low frequency; revenue

no_value_customers <- unique(customers$CustomerID[customers$log_revenue < 0] ) #Around 48 no vlaue customers!

#K-means is quite sensitive to outliers -- but in this case, these outliers give useful information about our customers -- therefore,
#we will not remove them from consideration!

#----------------CLUSTERING--------------------------

#k-means requires us to give the number of clusters required! 
#To get the optimal number of clusters -- we can do a number of things ---
#1. Elbow method
#2. Silhouette method
#3. Gap - Statistic method

#Goal is to group customers into high value and low value customers!

pre_processed <- customers[,9:11]

fviz_nbclust(pre_processed, kmeans,method = "wss")

#Therefore, the elbow method shows 4 as the optimal number of clusters

fviz_nbclust(pre_processed, kmeans,method = "silhouette")

#The Silhouette method gives 3 as the optimal number of clusters!

fviz_nbclust(pre_processed, kmeans,method = "gap_stat")

#Gap statistic also gives 3 as the optimal number of clusters!

#Lets try to visualize results for clusters 2 to 10 and compare results!

models <- data.frame(k=integer(),
                     tot.withinss=numeric(),
                     betweenss=numeric(),
                     totss=numeric(),
                     rsquared=numeric())


for (k in 1:10){
  
  output <- kmeans(pre_processed, centers = k,nstart = 20)
  
  variable_name <- paste("Cluster",k,sep = "_")
  
  customers[,(variable_name)] <- output$cluster
  
  customers[,(variable_name)] <- factor(customers[,(variable_name)], levels = c(1:k))
  
  
  
  #Graphing the clusters
  colors <- c('red','orange','green3','deepskyblue','blue','darkorchid4','violet','pink1','tan3','black')
  title <- paste("Cluster analysis with",k,"Clusters")
  
  p4 <- ggplot(data = customers,aes(x = log_frequency, y = log_revenue)) +
    geom_point(aes(color = customers[,(variable_name)])) + labs(color = "Cluster group") + ggtitle(title)
  
  print(ggplotly(p4))
  
  #Cluster centres in original metrics
  
  cluster_centres <- ddply(customers,.(customers[,(variable_name)]), summarize,
                           revenue = round(median(revenue),2),
                           recency = round(median(recency),2),
                           frequency = round(median(Frequency),2)
  )
  
  names(cluster_centres)[names(cluster_centres) == "customers[, (variable_name)]"] <- "Clusters"
  
  print(cluster_centres)
  cat("\n")
  cat("\n")
  #Model Information
  
  models[k,"k"] <- k
  models[k,"tot.withinss"] <- output$tot.withinss
  models[k,"betweenss"] <- output$betweenss
  models[k,"totss"] <- output$totss
  models[k,"rsquared"] <- output$betweenss/output$totss
  
}

#-----------Final Analysis------------------

#As the number of clusters increase, there interpretability is also affected.
#Cluster analysis with 2 clusters seems overly simplified!

#Cluster analysis with 3 clusters basically gives cluster 3 as high value customers, cluster 1 and 2 are similar (low value!)

#The decision should be based upon how the business plans to use the results, and the level of granularity they want to see in the clusters.
#I'd suggest 4 number of clusters should be good --- Cluster 4 -- high value customers; Cluster 1 and Cluster 2 -- mid value customers and
#Cluster 3 are the zero value customers with low frequency and low revenue and are not very recent.