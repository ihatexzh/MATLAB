
%capon波束形成器，也称MVDR波束形成器。
%它试图使噪声以及来自非θ方向的任何干扰所贡献的功率为最小,但又能保持在观测方向θ上的信号功率不变

%当权向量的方向角选择得和发送信号都不符合时，方向图零点的个数等于M-1；
%当权向量的方向角选择得和发送信号之一符合时，另一个信号的强烈干扰置为0
%信号中不再含有强干扰
%保证输出功率最小的同时，约束条件为W'*a(theta0)=1）

close all;    %关闭所有正在运行的窗口
clear all;    %清空缓存
clc;          %清屏命令窗口
M=10;          %假设空间阵列的 阵元数目 M=8
%X=[];         %阵元接收信号矢量为x(t)。某一固定时刻，接收信号是一个列向量X=[];
theta=[5 45 60];       %设置仿真所用的信号 入射角度，单位是度。仿真中，构造信号时作为已知量，估计的时候是不知道的
theta=theta.*pi/180;     %对上述单位为 度 的交度进行转换，化为 弧度 形式
d_=0.5;                   %因为距离d一般设置为波长λ的一半，所以此处直接令：d/λ=0.5
W=2*pi*d_.*sin(theta);    % 导向矢量中，三个信号源的 空间相位

%%%%      构造发送信号
N=400;                    %假设快拍数  N=1000
n=1:N;                     % n从1开始，以步长1 增长到 1000
s1=(10)*cos(2*pi*0.01*n);  %不考虑载波，此处设置三个信号s1,s2,s3 为幅度，频率都不相同的信号，
                           %因为信号频率不同，因此一定是非相干信号，其中的 n 代表该采样信号的采样时刻
                           % n 从1 到1000 ，每个信号Si 分别采样1000次，即每个信号有1000个样本点
s2=(17)*cos(2*pi*0.15*n);
s3=(28)*cos(2*pi*0.35*n);
noise=wgn(M,N,0);          %产生一个M*N 的高斯白噪声矩阵，噪声能量为 0dB。因为，假设已知噪声功率为1,所以：10*log1=0
                           % 注意：每个采样点在每个天线阵元上都要加入高斯白噪声
%%%%%%%    接收信号X
                                 % 注意，此处求接收信号矩阵X，是先求该矩阵中第m个阵元，q时刻的接收信号向量X(m,q)
 for m = 1:M                       % 大循环为 天线阵元M
     for q = 1:N                   % 小循环 为每个天线阵元上接收到的1000个采样信号点的值，q从1 到1000，默认步长为1
         Y = [s1(q) s2(q) s3(q)];  % 构造矩阵Y，其中元素为第q时刻，三个信号源的接收样值。
                                 % m代表第几个阵元，q代表接收信号的时刻点
         X(m,q) = Y(1)*exp(-j*(m-1)*W(1))+Y(2)*exp(-j*(m-1)*W(2))+Y(3)*exp(-j*(m-1)*W(3));
                                 %X(m，q)代表的是第m个阵元，第q时刻收到的信号
                                 %其中，W（i）是第i个信号源的加权值，
     end
 end
 X=X+noise;                      % 信号矩阵 X 加噪声
 R=X*X'/N;                       % 用时间平均估计空间 相关矩阵

 %   计算滤波器权向量
 v=1:M;
 theta0=45;                      % 允许50度，方向的信号通过，其他方向滤除
 theta0=theta0.*pi/180;          % 化为弧度形式
 fy0=2*pi*d_.*sin(theta0);       %
 a0=exp(-j*(v-1)*fy0);           % 将导向矢量 a(θ)中的元素表示出来，并赋值给a0
 a0=a0.'                         % 变为列向量，取共轭转置
 W0=inv(R)*a0/(a0'*inv(R)*a0);   %其中inv（R）是对自相关矩阵R取逆
 Y1=W0'*X
 Y2=a0'*X                        % 直接用另一个信号有干


%    方向图
 bianli=-pi/2:(pi/2)/1024:pi/2;
 bianli_thta=2*pi*d_*sin(bianli);
 L=length(bianli);
  for p=1:M
   for q=1:L
    A(p,q)=exp(-j*bianli_thta(q)*(p-1));
   end
  end
 F=[];
 k=1:L;
 F=1./abs(W0'* A(:,k));           % 所求得的加权向量W0和导向矩阵A的第K列相乘
                              % 其中 abs 是取绝对值运算，对于复数，是取模
  maxF=max(F);                 % 选出 方向图中 F的最大值，并赋值给maxF，以便后面归一化用
  G=F/maxF;                    % 归一化方向图G，使G的最大值为1
  plot(180*bianli/pi,G);

xlabel('方位 角（θ）');
ylabel('空间谱（dB） ');
title('Capon 波束形成器的空间谱');
% axis([-90 90]);
grid on;                    % 给 当前坐标轴添加主要的格点


