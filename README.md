# What is Customer-Segmentation?

As the name suggests, this project is about dividing the customer group into different segments. The idea is to group customers who share similar characteristics. How these groups are formed are based on business objectives and the data available. Through this project we can derive insights into Customer LifeTime Value, Purchase Channel and Product proclivities, so a business can tap into the information to guide future decisions.

Customer segmentation can be achieved using a variety of customer demographics such as age, gender, marital status, etc. However, such information is not easily available. What is easily available is TRANSACTIONAL DATA (Customer Accounts, Invoices, Invoice Dates and Times, etc.) How can the customers, now be segmented?

Although it depends on the business objectives, lets use RFM (Recency, Frequency and Monetary Value) metrics to identify high value and low value customers of the business, so that they can be used for marketing purposes.

# Data
The data was obtained from UCI Machine Learning repository https://archive.ics.uci.edu/ml/datasets/Online+Retail

![data](https://user-images.githubusercontent.com/45079009/84124483-24087280-a9f0-11ea-9b6c-75ac28f26589.PNG)


# RFM (Recency, Frequency and Monetary Value) Variables

As previously mentioned, the data did not include any demographic information of the customers, so using the new metrics to segment!

1. RECENCY -- How recently has the customer made his/her purchase?
2. FREQUENCY -- How frequent is the customer? How many purchases over the given time frame?
3. MONETARY VALUE -- How much amount does each customer bring in?

# Dealing with Outliers - A Pareto Analysis

The rule says that more or less, 80% of the results come from the 20% of the causes! In this context, 80% of sales are caused by 20% of the customers. Meaning, top 20% customers contribute most to the sales -- these are our high value customers!

-- Add graph

This is a very hard to read, reason being our RFM variables are highly skewed!

### Transformed RFM

-- Add new graph

Much better. Now, ....

-- Add pareto analysis result pic

Around 72% of the sales are caused by 28% of the customers. 
 
In our project, outliers are VERY IMPORTANT ! Outliers are customers who are either high value customers or are low value customers! Both of these groups present useful information. Therefore, I will include them in the analysis!


# Modelling - Using k-means!!!

# Why did I use k-means?

1. K-MEANS gives disjoint sets - I wanted each customer to belong to one and only one segment!
2. The data set had around 541,000 customers. Therefore, time complexity could be an issue. K-means has a linear time complexity O(n) as opposed to hierarchical which has a quadratic complexity - O(n^2)!

### What should be the optimal number of clusters?

To get the optimal number of clusters -- we can do a number of things ---
1. Elbow method - Gave us 3 cluster solution 
2. Silhouette method - Gave me 2 cluster solution
3. Gap - Statistic method - Gave me 2 cluster solution

-- add pics of all three




--- Visualize different cluster solution


# Final Analysis

As the number of clusters increase, there interpretability is also affected.

- Cluster analysis with 2 clusters seems overly simplified!

- Cluster analysis with 3 clusters basically gives cluster 3 as high value customers, cluster 1 and 2 are similar (low value!)

--- 3d cluster solution


# My take

The decision should be based upon how the business plans to use the results, and the level of granularity they want to see in the clusters. I'd suggest 4 number of clusters should be good --- Cluster 4 -- high value customers; Cluster 1 and Cluster 2 -- mid value customers and Cluster 3 are the zero value customers with low frequency and low revenue and are not very recent.
