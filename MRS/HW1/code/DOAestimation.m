function [doa_CBF, angle]= DOAestimation(X, M, N, P)
% 波达方向估计
% X 接收的信号
% M 阵元数
% N 采样点数
% P 信源个数
    R=X*X'/N;
    angle = -90:0.01:90;
    for i =1:length(angle)
        a = exp(-j*2*pi*0.5*[0:M-1]'*sin(pi*angle(i)/180));
        y_CBF(i) = sqrt(abs(a'*R*a));
    end
    doa_CBF = ESA(angle, y_CBF, P);
end