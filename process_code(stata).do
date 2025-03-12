**stata处理全过程
**数据预处理：

encode 地区, gen(id)
xtset id 时间

*Z-score标准化
norm variables, method(zee)

**# Bookmark #4
*碳排放
**移动平均填补缺失值
by id: mipolate 煤炭消费量万吨 时间, gen(value1) idw(2)
by id: mipolate 汽油消费量万吨 时间, gen(value2) idw(2)
by id: mipolate 燃料油消费量万吨 时间, gen(value3) idw(2)
by id: mipolate 柴油消费量万吨 时间, gen(value4) idw(2)
by id: mipolate 焦炭消费量万吨 时间, gen(value5) idw(2)
by id: mipolate 煤油消费量万吨 时间, gen(value6) idw(2)
by id: mipolate 天然气消费量亿立方米 时间, gen(value7) idw(2)
**各指标计算
gen v1=value1*1.647
gen v2=value2*3.045
gen v3=value3*3.064
gen v4=value4*3.150
gen v5=value5*2.848
gen v6=value6*3.045
gen v7=value7*21.670
gen V=v1+v2+v3+v4+v5+v6+v7
gen ln碳排放=log(V)
export excel using "D:\Desktop\碳排放-ma.xlsx", firstrow(variables) replace


**# Bookmark #6
*数字化水平
**移动平均填补缺失值
*1
by id: mipolate 互联网宽带接入用户万户 时间, gen(value_new) idw(2)
gen 互联网普及率 = value_new/总人口万人
export excel using "D:\Desktop\互联网普及率-ma.xlsx", firstrow(variables) replace

*2
by id: mipolate 城镇就业人员数万人 时间, gen(value_new) idw(2)
gen 互联网就业占比 = 信息传输软件和信息技术服务业城镇单位就业人员万人/value_new
export excel using "D:\Desktop\互联网就业占比-ma.xlsx", firstrow(variables) replace

*3
gen 人均电信业务总量 = (电信业务总量亿元*10000)/总人口万人
export excel using "D:\Desktop\人均电信业务总量-ma.xlsx", firstrow(variables) replace

*4
export excel using "D:\Desktop\移动电话普及率-ma.xlsx", firstrow(variables) replace

*5
by id: mipolate 数字金融普惠指数 时间, gen(value_new) idw(2)
export excel using "D:\Desktop\数字金融普惠指数-ma.xlsx", firstrow(variables) replace

*6
by id: mipolate 专利申请数件 时间, gen(value_new) idw(2)
gen ln专利申请数=log(value_new)
export excel using "D:\Desktop\高技术专利申请量-ma.xlsx", firstrow(variables) replace


**# Bookmark #8
*其他控制变量
**移动平均填补缺失值
*1 创新规模
by id: mipolate RD经费万元 时间, gen(value_new) idw(2)
gen v=value_new*10000
gen lnRD经费=log(v)
export excel using "D:\Desktop\创新规模-ma.xlsx", firstrow(variables) replace

*2经济规模
gen ln人均国内总产值=log(人均国内总产值元)
export excel using "D:\Desktop\经济规模-ma.xlsx", firstrow(variables) replace

*3产业结构
gen 产业结构=第三产业增加值亿元/第二产业增加值亿元
export excel using "D:\Desktop\产业结构-ma.xlsx", firstrow(variables) replace

*4人口结构
by id: mipolate 城镇人口数万人 时间, gen(value_new) idw(2)
gen 人口结构=value_new/总人口万人
export excel using "D:\Desktop\人口结构-ma.xlsx", firstrow(variables) replace

*5城镇化
by id: mipolate 建成区面积平方公里 时间, gen(value_new) idw(2)
gen ln建成区面积=log(value_new)
export excel using "D:\Desktop\城镇化-ma.xlsx", firstrow(variables) replace

*6消费能力
gen 消费能力=社会消费品零售总额亿元/国内生产总值增加值当年价亿元
export excel using "D:\Desktop\消费能力-ma.xlsx", firstrow(variables) replace

*7公共设施
export excel using "D:\Desktop\公共设施-ma.xlsx", firstrow(variables) replace

*8环境规制
gen 工业增加值万元=工业增加值亿元*10000
gen 环境规制=工业污染治理完成投资万元/工业增加值万元
export excel using "D:\Desktop\环境规制-ma.xlsx", firstrow(variables) replace



**PCA降维（系统已自动标准化）
encode 地区, gen(id)
xtset id 时间

*PCA
factortest a b c1 d e f	/*kmo=0.731，通过检验*/
pca a b c1 d e f		/*自动生成主成分得分c1-c7，选择3个主成分，解释力度在86.5%*/
predict pc1 pc2 pc3
gen total=(pc1*0.5604+pc2*0.1669+pc3*0.1377)/0.865 /*计算综合得分*/
sum total
/*后续考虑对得分为负值进行调整，取最小负值-2.141882*/
export excel using "D:\Desktop\数字化综合得分.xlsx", firstrow(variables) replace




*导入数据
use "D:\Desktop\data.dta", clear
encode 地区, gen(id)
xtset id 时间

**过程步骤
gen digtital_sqr=digital_aj*digital_aj	/*生成平方项后续备用*/


**# Bookmark #2
*共线性检验（VIF）+描述性统计(具体需要哪些变量后续调整)
reg  co2 digital_aj innova economy industry population city consumption environment infrastructure
estat vif

reg  co2 digital_aj economy industry population city consumption environment infrastructure
estat vif

sum co2 digital_aj economy industry population city consumption environment infrastructure

/*方差膨胀因子均小于10，通过检验*/


**基准面板回归：不带二次项
*模型选择
reg co2 digital_aj digital_sqr economy industry population city consumption environment infrastructure, vce(cluster id)
est store ols		/*混合回归*/

xtreg co2 digital_aj digital_sqr economy industry population city consumption environment infrastructure, fe
est store fe		/*固定效应*/
xtreg co2 digital_aj digital_sqr economy industry population city consumption environment infrastructure, re	
est store re		/*随机效应*/
**检验
xttest0		/*选择随机or回归：随机*/
hausman fe re, constant sigmamore	/*选择固定or随机：固定*/
**输出结果
esttab ols fe re, b se mtitle

***带二次项：
*模型选择
reg co2 digital_aj digital_sqr economy industry population city consumption environment infrastructure, vce(cluster id)
est store ols		/*混合回归*/
xtreg co2 digital_aj digital_sqr economy industry population city consumption environment infrastructure, fe
est store fe		/*固定效应*/
xtreg co2 digital_aj digital_sqr economy industry population city consumption environment infrastructure, re	
est store re		/*随机效应*/
xtreg co2 digital_aj digital_sqr economy industry population city consumption environment infrastructure i.时间, fe	/*双固定*/
est store ffe
**检验
xttest0		/*选择随机or回归：随机*/
hausman fe re, constant sigmamore	/*选择固定or随机：固定*/
**输出结果
esttab ols fe re ffe, b se mtitle




**# Bookmark #4
**空间面板回归
use "D:\Desktop\data.dta", clear
spatwmat using w4.dta, name(W4) standardize
matrix list W4
forvalue i==2010/2022{
	preserve
	keep if 时间==`i'
	spatgsa co2, weights(W4) moran geary twotail	/*全局莫兰指数*/
	restore
}
/*按年做*/
*局部莫兰指数
clear
use "D:\Desktop\data.dta"
encode 地区, gen(id)
xtset id 时间
spatwmat using w4.dta, name(W4) standardize
preserve
keep if 时间==2022
spatlsa co2, weights(W4) moran twotail		/*局部莫兰指数*/
restore
*散点图/*后续调整年份*/
preserve
keep if 时间==2022
spatlsa co2, weights(W4) moran graph(moran) symbol(id) id(地区)
restore

*模型检验
*1 LM
clear all
use "D:\Desktop\data.dta", clear
use w4
spcs2xt 上海市-黑龙江省, matrix(aaa) time(13)
spatwmat using aaaxt, name(W0)
clear
use "D:\Desktop\data.dta"
encode 地区, gen(id)
xtset id 时间
reg co2 digital_aj digital_sqr economy industry population city consumption environment infrastructure
spatdiag,weights(W0)

*2 Wald
clear
use "D:\Desktop\data.dta"
spatwmat using w4.dta, name(W4) standardize
matrix list W4
encode 地区, gen(id)
xtset id 时间
xsmle co2 digital_aj digital_sqr economy industry population city consumption environment infrastructure, fe model(sdm) wmat(W4) type(both) nolog noeffects
//Wald for SAR
test [Wx]digital_aj=[Wx]digital_sqr=[Wx]economy=[Wx]industry=[Wx]population=[Wx]city=[Wx]consumption=[Wx]environment=[Wx]infrastructure=0
//Wald for SEM
testnl ([Wx]digital_aj=-[Spatial]rho*[Main]digital_aj)([Wx]digital_sqr=-[Spatial]rho*[Main]digital_sqr)([Wx]economy=-[Spatial]rho*[Main]economy)([Wx]industry=-[Spatial]rho*[Main]industry)([Wx]population=-[Spatial]rho*[Main]population)([Wx]city=-[Spatial]rho*[Main]city)([Wx]consumption=-[Spatial]rho*[Main]consumption)([Wx]environment=-[Spatial]rho*[Main]environment)([Wx]infrastructure=-[Spatial]rho*[Main]infrastructure)

*3 LR
xsmle co2 digital_aj digital_sqr economy industry population city consumption environment infrastructure, fe model(sdm) wmat(W4) type(both) nolog noeffects
est store sdm
xsmle co2 digital_aj digital_sqr economy industry population city consumption environment infrastructure, fe model(sar) wmat(W4) type(both) nolog noeffects
est store sar
xsmle co2 digital_aj digital_sqr economy industry population city consumption environment infrastructure, fe model(sem) emat(W4) type(both) nolog noeffects
est store sem
lrtest sdm sar
lrtest sdm sem

*4 Hausman
use "D:\Desktop\data.dta", clear
encode 地区, gen(id)
xtset id 时间
spatwmat using w4.dta, name(W4) standardize
xsmle co2 digital_aj digital_sqr economy industry population city consumption environment infrastructure, fe model(sdm) wmat(W4) type(both) nolog noeffects
est store fe
xsmle co2 digital_aj digital_sqr economy industry population city consumption environment infrastructure, re model(sdm) wmat(W4) type(both) nolog noeffects
est store re
hausman fe re

*固定效应类型（个体/时间）
use "D:\Desktop\data.dta", clear
encode 地区, gen(id)
xtset id 时间
spatwmat using w4.dta, name(W4) standardize
xsmle co2 digital_aj digital_sqr economy industry population city consumption environment infrastructure, fe model(sdm) wmat(W4) type(ind) nolog noeffects
est store ind
xsmle co2 digital_aj digital_sqr economy industry population city consumption environment infrastructure, fe model(sdm) wmat(W4) type(time) nolog noeffects
est store time
xsmle co2 digital_aj digital_sqr economy industry population city consumption environment infrastructure, fe model(sdm) wmat(W4) type(both) nolog noeffects
est store both
lrtest both ind, df(20)	/*双向or个体*/
lrtest both time, df(20)	/*双向or时间，都通过就用双固定*/

*效应分解
use "D:\Desktop\data.dta", clear
encode 地区, gen(id)
xtset id 时间
spatwmat using w4.dta, name(W4) standardize
xsmle co2 digital_aj economy industry population city consumption environment infrastructure, fe model(sdm) wmat(W4) type(ind) nolog noeffects

xsmle co2 digital_aj digital_sqr economy industry population environment infrastructure, fe model(sdm) wmat(W4) type(both) nolog noeffects		/*删除了部分变量，这个结果不错*/
**于是效应分解有：
xsmle co2 digital_aj digital_sqr economy industry population environment infrastructure, fe model(sdm) wmat(W4) type(both) nolog effects robust	
est store aa
esttab aa, b se mtitle

*稳健性检验(缩短年限试一试，剔除2011年/2012年；采用滞后一期的稳健性检验)
use "D:\Desktop\data.dta", clear
encode 地区, gen(id)
xtset id 时间
drop if 时间==2011
xsmle co2 digital_aj digital_sqr economy industry population environment infrastructure, fe model(sdm) wmat(W4) type(both) nolog effects

use "D:\Desktop\data.dta", clear
encode 地区, gen(id)
xtset id 时间
gen lco2=l1.co2
gen llco2=l2.co2
gen lllco2=l3.co2
by id: ipolate lco2 时间,gen(lco2_1) epolate
xsmle co2 lco2_1 lco2_2 digital_aj digital_sqr economy industry population environment infrastructure, fe model(sdm) wmat(W4) type(both) nolog effects robust

by id: ipolate llco2 时间,gen(lco2_2) epolate
xsmle lco2_2 digital_aj digital_sqr economy industry population environment infrastructure, fe model(sdm) wmat(W4) type(both) nolog effects robust

by id: ipolate lllco2 时间,gen(lco2_3) epolate
xsmle lco2_3 digital_aj digital_sqr economy industry population environment infrastructure, fe model(sdm) wmat(W4) type(both) nolog effects robust		/*不显著，删掉*/


use "D:\Desktop\data.dta", clear	/*剔除最高的和最低的1%样本*/
encode 地区, gen(id)
xtset id 时间
winsor2 co2, replace cuts(1 99) trim
by id: ipolate co2 时间,gen(pco2) epolate
xsmle pco2 digital_aj digital_sqr economy industry population environment infrastructure, fe model(sdm) wmat(W4) type(both) nolog effects




***封底在此
