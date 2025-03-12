# Walmart Customer Analysis Visualization
the data is provided by Kaggle: <https://www.kaggle.com/datasets/devarajv88/walmart-sales-dataset>  
  🔎 This dataset focuses on Walmart's customer transactions, capturing detailed information on user demographics, product categories, and purchase amounts. 
It includes unique user and product identifiers, gender, age groups, occupation (masked), city categories, duration of stay in the current city, marital status, product categories (masked), and purchase amounts.

In my code, I made some basic data cleaning and visualization, and machine learning method(**Kmeans, Market basket analysis and association rule mining**), and the pictures(partly displayed here) are as follows:

![用户性别年龄情况](https://github.com/user-attachments/assets/5c7b1591-1fd1-49ea-acd1-879eea28afc1)  
As can be seen from the above figure, the main user group of Walmart's e-commerce platform is male, and the number of male users is significantly more than that of female users, accounting for 71.72% and 28.28% of the total number, respectively. 
From the perspective of age, the user age is mainly concentrated in the 26-35 years old range, accounting for 34.85%. It was followed by 18-25 years old and 36-45 years old, accounting for 18.15% and 19.81%, respectively.  
Users are also partially distributed in other age groups. This shows that the platform has a certain appeal to users of different ages and can better grasp the mainstream customer groups in the current retail industry.


![产品销量排行](https://github.com/user-attachments/assets/76a0e5f2-67dc-4585-aa39-e2b7964f51cb)  
According to statistics, there are 3,631 different items for sale in 20 categories on Walmart's online retail store. According to the above figure, the top 10 best-selling commodities are P00265242, P00025442, P00110742, P00112142, P00057642, 
P00184942, P00046742, P00058042, P00059442, and P00145042.



![AGP聚类散点图](https://github.com/user-attachments/assets/4207ed89-693c-4816-8e6a-89d90bed0de0)  
As can be seen from the figure above, gender and age group have a significant impact on total purchases. In group 2 with high purchasing power, the age group with the highest total purchasing power is 26-45 years old, while the purchasing power of men is relatively higher than that of women, and the difference is particularly obvious in the age group 51-55 years old and over 55 years old. 
The age distribution of group 1, 3 and 4 is even, but the purchasing power of males in group 4 is significantly higher than that of females between the ages of 0-17 and over 55, while the purchasing power of group 1 is broader than that of group 3. Relatively speaking, women have more medium consumption groups than men, and men have significantly more high consumption groups than women.


![CYP聚类散点图](https://github.com/user-attachments/assets/ead0ff3f-4686-4be7-9b8c-35c72a7522c4)  
The regional characteristics of different purchasing power groups are further analyzed. From the perspective of different city categories, the total purchase volume of area A and area B is relatively high, especially for group 2 whose residence duration is 3 or 4 years or more. 
In both regions, there is a gradual increase in total purchases as the number of years of residence increases. However, the total purchases in region C are relatively the lowest, and the number of years of residence has little effect on the total purchases.  
In terms of different groups, group 2 with high purchasing power is mainly distributed in region A and region B, while group 3 with high purchasing power in the middle is distributed in different regions and is the backbone group contributing to the purchase volume in different regions. 
In addition, in the visual analysis not shown, the number of distribution in regions A, B and C shows A trend of ladder rise, but the level of purchasing power in regions A, B and C decreases in turn. This shows that there is a significant difference in the market penetration of Walmart's e-commerce platform in different regions, and the user value varies greatly in different regions. 
At present, there is still room for further improvement in user development of region A and B, and the scale of high-value user groups attracted is small, so it needs to be further broken to promote performance growth.
