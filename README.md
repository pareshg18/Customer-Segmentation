# What is Customer-Segmentation?

As the name suggests, this project is about dividing the customer group into different segments. The idea is to group customers who share similar characteristics. How these groups are formed are based on business objectives and the data available. Through this project we can derive insights into Customer LifeTime Value, Purchase Channel and Product proclivities, so a business can tap into the information to guide future decisions.

Customer segmentation can be achieved using a variety of customer demographics such as age, gender, marital status, etc. However, such information is not easily available. What is easily available is TRANSACTIONAL DATA (Customer Accounts, Invoices, Invoice Dates and Times, etc.) How can the customers, now be segmented?

Although it depends on the business objectives, lets use RFM (Recency, Frequency and Monetary Value) metrics to identify high value and low value customers of the business, so that they can be used for marketing purposes.

# Data
The data was based on the past purchases of the customers, so, it had information like Invoice number, data of purchase, item purchased, quantity and unit prices of each item purchased.

![alt text](https://github.com/[pareshg18]/[Customer-Segmentation]/blob/[branch]/data.png?raw=true)



# Feature Engineering

The data set did not include any demographic information of the customers, so i came up with new metrics to segment them!

I used the RFM model. I calculated 3 different scores for each customer:

#1. RECENCY -- How recently has the customer made his/her purchase?
#2. FREQUENCY -- How frequent is the customer? How many purchases over the given time frame?
#3. MONETARY VALUE -- How much amount does each customer bring in?


# Modelling - Using k-means!!!

# Why did I use k-means?

1. K-MEANS gives disjoint sets - I wanted each customer to belong to one and only one segment!
2. The data set had around 541,000 customers. Therefore, time complexity could be an issue. K-means has a linear time complexity O(n) as opposed to hierarchical which has a quadratic complexity - O(n^2)!

# Data Preparation

K-means gives the best result under the following conditions:
1. Data’s distribution is not skewed (i.e. long-tail distribution)
2. Data is standardised (i.e. mean of 0 and standard deviation of 1).

I took the log- transform and normalizing the RFM metrics using z-score!

# Outliers

They affect the final cluster solution.

 -- Pareto Analyis (80/20 rule)  - revealed around 72% of the sales are caused by 28% of the customers. 
 
 Here, outliers are customers who are either high value customers or are low value customers! Both of these groups present useful information therefore, I did not remove them from consideration!


# K-means - What should be the best cluster solution?

To get the optimal number of clusters -- we can do a number of things ---
1. Elbow method - Gave us 3 cluster solution 
2. Silhouette method - Gave me 2 cluster solution
3. Gap - Statistic method - Gave me 2 cluster solution


# Final Analysis

As the number of clusters increase, there interpretability is also affected.

- Cluster analysis with 2 clusters seems overly simplified!

- Cluster analysis with 3 clusters basically gives cluster 3 as high value customers, cluster 1 and 2 are similar (low value!)

# My take

The decision should be based upon how the business plans to use the results, and the level of granularity they want to see in the clusters. I'd suggest 4 number of clusters should be good --- Cluster 4 -- high value customers; Cluster 1 and Cluster 2 -- mid value customers and Cluster 3 are the zero value customers with low frequency and low revenue and are not very recent.
