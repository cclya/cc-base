/*实验内容：
1.选定一个记录数量符合要求且存在季节性变化的数据集（可为来自任何领域的数据）。
2.进行ADF单位根检验，对数据特征进行初步观察，确定是否需要差分及差分阶数。
3.绘制自相关函数和偏自相关函数图，基于ACF和PACF图的观察结果识别序列特征。
4.建立ARIMA(p,d,q)*(p,d,q)s模型并进行模型诊断和评估。
*/

data expmon;
input teiv@@;
date=intnx('month','1jan10'd,_n_-1);
format date monyy.;
cards;
2050.07
1815.31
2315.23
2382.83
2438.62
2545.29
2622.62
2585.55
2731.19
2448.44
2842.64
2955.94
2955.27
2011.65
3044.58
2999.22
3011.19
3015.96
3199.7
3287.87
3247.79
2978.92
3341.08
3327.87
2726.67
2607.99
3259.86
3077.49
3439.24
3281.54
3285.75
3293.68
3449.18
3190.08
3391.28259
3669.48
3464.37
2637.63
3652.1
3556.96
3449.81
3213.42
3541.52
3527.04
3560.699
3397.34
3705.58
3895.81
3823.94944
2511.76182
3325.12681
3586.28525
3550.2411
3420.12378
3784.81575
3670.95251
3964.1157
3683.27943
3688.4896
4054.13212
3404.84185
2777.62096
2860.55898
3185.27152
3212.47714
3374.12104
3471.68095
3334.96775
3507.67303
3231.48187
3391.81636
3879.7784
2910.84568
2196.97006
2917.69733
2999.58011
3121.43222
3124.59054
3150.56873
3291.35339
3270.18366
3069.6967
3428.63237
3780.16588
;
run;
proc gplot data=expmon;
symbol1 i=spline v=dot c=red;
plot teiv*date=1;
run;
data lmon;
set expmon;
lteiv=log(teiv);
run;
proc gplot data=lmon;
symbol2 i=spline c=green;
plot lteiv*date=2;
run;
proc arima data=lmon;
identify var=lteiv(1) nlag=36;
run;
identify var=lteiv(1,12) nlag=36;
run;

estimate q=(1)(12) method=uls plot;
run;
estimate p=(2)(12) method=uls plot;
run;
estimate p=(2)(12) q=(1)(12) method=uls plot;
run;

forecast lead=24 interval=month id=date out=results;
run;
data result;
set results;
teiv=exp(lteiv);
l95=exp(l95);
u95=exp(u95);
forecast=exp(forecast);
run;
symbol1 i=spline c=green;
symbol2 i=spline c=blue;
proc gplot data=result;
plot teiv*date=1 forecast*date=2/overlay;
run;
quit;
