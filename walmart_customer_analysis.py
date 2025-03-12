import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
from sklearn.cluster import KMeans
from sklearn import metrics
import warnings
warnings.filterwarnings('ignore')
colors = ['#f7acad', '#a3def4', '#fed6ad', '#c7e1a6',
          '#edd7d7', '#85d4dc', '#fed477', '#adc299',
          '#b66fb3', '#392767']

#导入数据
walmart = pd.read_csv('D:/Desktop/walmart.csv')
walmart.head()
#数据清洗：重复值、缺失值、异常值
print(walmart.shape)
walmart.info()
walmart.nunique()
walmart.duplicated().sum()
#字段检查：
walmart['Gender'].value_counts()
walmart['Age'].value_counts()
walmart['Occupation'].value_counts()
walmart['Stay_In_Current_City_Years'].value_counts()
walmart['Product_Category'].value_counts()
#数据转换：按首字母/数字大小进行顺序编码
from sklearn.preprocessing import LabelEncoder
for i in ['Gender', 'Age', 'City_Category', 'Stay_In_Current_City_Years']:
    walmart[i] = LabelEncoder().fit_transform(walmart[i])
#计算每个顾客的累计消费金额
temp = walmart.pivot_table(index='User_ID',values=['Purchase']
,aggfunc={'Purchase':'sum'})
temp.columns = ['Total_Purchase']
walmart = pd.merge(walmart,temp,on='User_ID',how='left')
#Z-score
def Z_Score(data):
    mean = np.mean(data)    # 均值
    std_dev = np.std(data)    # 标准差
    norm_data = (data - mean) / std_dev
    return norm_data
norm_data = Z_Score(walmart['Total_Purchase'])
norm_data.to_csv('D:/Desktop/norm.csv', index = False)     #存储转换后的数据1
walmart.to_csv('D:/Desktop/dpc.csv', index = False)



## 用户基本分析
x = pd.read_csv('D:/Desktop/profile3.csv')
# 性别*年龄分布
x_st = x.groupby('Gender')['Age'].value_counts()
x_st1 = x_st.reset_index()
ax2 = sns.barplot(x='Age', y='count', hue="Gender", width=0.8,
                  order=x_st1.index.tolist(), palette=colors, data=x_st1)
ax2.set_xticks([0, 1, 2, 3, 4, 5, 6])
ax2.set_ylabel('Count')
ax2.set_xlabel('Age Band')
plt.tight_layout()
plt.show()
ax2.set_xticklabels(['0-17', '18-25', '26-35', '36-45', '46-50', '51-55', '55+'])

# 城市用户分布
x_sta = x['City_Category'].value_counts()
x_sta1 = x_sta.reset_index()
ax1 = sns.barplot(x='City_Category', y='count',hue="City_Category",
                  order=x_sta.index.tolist(),palette=colors, data=x_sta1)
ax1.set_ylabel('Count')
ax1.set_xlabel('City Category')
ax1.set_xticklabels(['C', 'B', 'A'])
plt.show()
plt.legend().remove()


## 商品销售分析
df = pd.read_csv('D:/Desktop/dpc.csv')

# 选出所需字段，添加一列表示顾客购买了该商品
buyer_product = df[['User_ID','Product_ID']]
buyer_product['Count'] = pd.Series([1 for i in range(len(buyer_product))])
# group by User_ID, 每个商品为一列
buyer_basket = buyer_product.pivot_table(values = 'Count',index=['User_ID'], columns=['Product_ID']).reset_index()
# 用0填充空值
buyer_basket = buyer_basket.fillna(0)
buyer_basket.head()
# 计算每个顾客买了多少种商品
buyer_basket.loc[:,'Total'] = buyer_basket.drop('User_ID',axis = 1).sum(axis=1)
buyer_basket.head()
print('沃尔玛电商商品统计中，共有',buyer_basket.iloc[:,2:].shape[1],'不同的商品')

# 移除“用户_ID”列，剩下的用于后续分析
basket_data = buyer_basket.iloc[:,1:]
# 计算每个商品出现频率
basket_data.loc['Total', :] = basket_data.sum(axis=0)
basket_data.tail()
# 统计商品出现频率
product_frequency = basket_data.iloc[-1, :].sort_values(ascending=False)
product_frequency.head(6)
# 结果可视化
import plotly.offline as py
from plotly.graph_objs import Bar, Layout, Figure
trace = Bar(x=product_frequency.index[1:11], y=product_frequency.values[1:11], marker=dict(color=colors),
           text=product_frequency.values[1:11], textposition='inside')
layout = Layout(title=" ", width=900, height=400,
               xaxis=dict(title='Product_ID'), yaxis=dict(title="Frequency"))
py.plot(Figure(data=[trace], layout=layout))
# 商品集合大小分布
products_length = basket_data.iloc[:-1,:].groupby(by='Total').size().reset_index(name='Count').rename(columns={'Total': 'ItemsetSize'})
products_length.head(10)
basket_products = basket_data.iloc[:-1,-1] # 去除total行与total列的纯商品数据
basket_products.describe()
out = basket_products.describe()
out1 = out.reset_index()

# K-Means聚类分析
#1.数据准备
x = pd.read_csv('D:/Desktop/profile3.csv')
x1 = x[['Gender', 'Z_TPurchase']]

#2.1.1肘部法则确定K值：
sse = []
for n in range(2, 10):
    kmeans = KMeans(n_clusters=n, random_state=123, max_iter=50)
    # max_iter单次运行的最大迭代次数50；random_state随机数种子，控制每次运行的结果一致
    kmeans.fit(x1)
    sse.append(kmeans.inertia_)
plt.plot(sse)
plt.show()
#2.1.2轮廓系数法确定K值
sa = []
for n in range(2,10):
    kmeans = KMeans(n_clusters=n,random_state=123,max_iter=50)
    #max_iter单次运行的最大迭代次数50
    kmeans.fit(x1)
    cluster_labels = kmeans.labels_ #要赋值出来
    # silhouette score
    silhouette_avg = metrics.silhouette_score(x1, cluster_labels)
    sa.append(silhouette_avg)
plt.plot(sa)
plt.show()
##综合上述结果，选择k=4，拟合模型
kmeans = KMeans(n_clusters=4, random_state=123)
kmeans.fit(x1)
kmeans.inertia_
kmeans.labels_
##将分簇后对应的标签 赋值给原表，新增一列
c = pd.DataFrame(kmeans.labels_)
c.columns = ['labels']
c['labels'] = c['labels'].astype('category')
x['labels'] = c['labels'].values
x2 = x.drop(columns=['Z_TPurchase'])
x2.head()
x2.to_excel('D:/Desktop/kmeansresult.xlsx', index=False)    #保存结果进行分析


#聚类结果占比图
x2 = pd.read_excel('D:/Desktop/kmeansresult.xlsx')
diy = ['#78b9d2','#8fb943','#f5cf36','#d15c6b','#8386a8']
pic1 = x2['labels'].value_counts()
explode = [0.01,0.01,0.01,0.01]
oc = {0:'#78b9d2', 1:'#8fb943', 2:'#f5cf36', 3:'#d15c6b'}

plt.pie(pic1, labels=pic1.index,
        colors=[oc[index] for index in pic1.index],
        explode=explode, autopct='%1.2f%%')
##如进行分组标签排列：
order = {0:'Group-1', 1:'Group-2', 2:'Group-3', 3:'Group-4'}
plt.pie(pic1, labels=[order[index] for index in pic1.index],
        colors=[oc[index] for index in pic1.index],
        explode=explode, autopct='%1.2f%%')

#AGE、Gender、Total_Purchase三维展示图
fig = plt.figure(figsize = (15,15))
ax = plt.axes(projection='3d')
ax.scatter3D(x2['Age'], x2['Gender'], x2['Total_Purchase'], marker='o',
             c=[diy[label] for label in x2['labels'].astype(int)])
ax.set_xticks([0, 1, 2, 3, 4, 5, 6])
ax.set_yticks([0, 1])
# 设置坐标轴的刻度标签
ax.set_yticklabels(['Female', 'Male'])
ax.set_xticklabels(['0-17', '18-25', '26-35', '36-45', '46-50', '51-55', '55+'])
ax.set_xlabel('Age')
ax.set_ylabel('Gender')
ax.set_zlabel('Total Purchase')
plt.show()

#City_Category, Stay_In_Current_City_Years、Total_Purchase三维展示图
fig = plt.figure(figsize = (15,15))
ax = plt.axes(projection='3d')
ax.scatter3D(x2['City_Category'], x2['Stay_In_Current_City_Years'], x2['Total_Purchase'], marker='o',
             c=[diy[label] for label in x2['labels'].astype(int)])
ax.set_xticks([0, 1, 2])
ax.set_yticks([0, 1, 2, 3, 4])
# 设置坐标轴的刻度标签
ax.set_xticklabels(['A', 'B', 'C'])
ax.set_xlabel('City Category')
ax.set_ylabel('Stay In Current City Years')
ax.set_zlabel('Total Purchase')
plt.show()
