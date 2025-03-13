/*实验内容：
1.选定一个记录数量符合要求的数据集（可为来自任何领域的数据）。
2.进行ADF单位根检验，对数据特征进行初步观察。
3.绘制自相关函数和偏自相关函数图，基于ACF和PACF图的观察结果识别序列特征。
4.建立ARMA模型并进行模型诊断和评估。
*/

data gnpexp;
input gnp@@;
date=intnx('year','31Dec52'd,_n_-1);
format date year4.;
cards;
194.3
253.5
255.3
266.8
303.4
321.0
377.6
439.7
468.1
390.0
336.9
328.2
381.5
462.8
456.3
456.9
459.5
512.6
547.2
577.3
606.5
640.4
652.7
655.7
639.5
750.7
905.12494
916.14785
1023.41482
1121.1284
1214.03813
1397.05031
1858.15182
2670.84335
3096.97853
3696.29915
4742.01439
5650.83474
6111.55829
7587.21872
9669.23457
12312.97081
16713.1198
20642.67561
24108.03026
27904.79121
31559.252
34935.5232
39899.11601
45701.24524
51423.11036
57756.02992
66650.86031
77430.00302
91762.2401
115787.6744
136827.538
154765.1146
182061.8903
216123.621
244856.249
277983.5428
310653.9632
349744.65
390828.06
438355.9474
489700.7626
535370.9907
551973.7482
614476.4472
638697.6252
;
run;
proc gplot data=gnpexp;
symbol1 i=spline;
plot gnp*date=1;
run;
data lexp;
set gnpexp;
lgnp=log(gnp);
run;
proc gplot data=lexp;
symbol2 i=spline c=red;
plot lgnp*date=2;
run;
proc arima data=lexp;
identify var=lgnp(1) nlag=12;
run;
estimate p=1 plot;
run;
forecast lead=6 interval=year id=date out=results;
run;
identify var=lgnp(1) esacf p=(0:10) q=(0:10) nlag=24;		/*扩展样本自相关*/
run;

/*以下为非差分做的结果，不可靠*/
identify var=lgnp esacf p=(0:10) q=(0:10) nlag=24;		/*扩展样本自相关*/
run;
estimate p=1 plot;
run;
estimate q=7 plot;
run;
estimate p=(1,2) q=1 plot;
run;
forecast lead=6 interval=year id=date out=results;
run;
data result;
           set results;
           gnp=exp(lgnp);
           l95=exp(l95);
           u95=exp(u95);
           forecast=exp(forecast);
       run;
symbol1 i=spline c=green;
symbol2 i=spline c=red;
proc gplot data=result;
plot gnp*date=1 forecast*date=2/overlay;
run;
quit;
