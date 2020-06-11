-- THIS ANALYSIS IS DONE IN R USING JUPYTER NOTEBOOK --

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

![outliers](https://user-images.githubusercontent.com/45079009/84260997-dfec9f00-aacf-11ea-840c-109c080541ea.png)

This is a very hard to read, reason being our RFM variables are highly skewed!

### Transformed RFM

![outliers_transformed](https://user-images.githubusercontent.com/45079009/84324040-ca599280-ab2c-11ea-84d7-b58eef9d905a.png)

In this project, outliers are VERY IMPORTANT ! Outliers are customers who are either high value customers or are low value customers! Both of these groups present useful information. Therefore, I will include them in the analysis!


# Modelling - Using k-means!!!

### Why did I use k-means?

1. K-MEANS gives disjoint sets - I wanted each customer to belong to one and only one segment!
2. The data set had around 541,000 customers. Therefore, time complexity could be an issue. K-means has a linear time complexity O(n) as opposed to hierarchical which has a quadratic complexity - O(n^2)!

### Optimal number of clusters?

To get the optimal number of clusters -- we can do a number of things ---
1. Elbow method - Gave me 2 or 3 cluster solution 
2. Silhouette method - Gave me 2 cluster solution
3. Gap - Statistic method - Gave me 6 cluster solution

![elbow](https://user-images.githubusercontent.com/45079009/84262492-918ccf80-aad2-11ea-8d62-5dec4435985e.PNG)![gap-statistic](https://user-images.githubusercontent.com/45079009/84262494-92256600-aad2-11ea-89bd-d6c34f209b2d.PNG)![silhouette](https://user-images.githubusercontent.com/45079009/84262495-92bdfc80-aad2-11ea-85ba-04710547f0b9.PNG)


# Final Cluster Solution

![final solution](https://user-images.githubusercontent.com/45079009/84268346-5bece400-aadc-11ea-95d4-b23007db7bba.PNG)


# My take

The decision should be based upon how the business plans to use the results, and the level of granularity they want to see in the clusters. In my opinion, 4 cluster-solution should be the best, where 1 group is high value customers; 2 groups mid value customers and 1 group being the zero value/low value customers with low frequency and low revenue and who were not very recent.
