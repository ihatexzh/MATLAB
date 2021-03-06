clear all
clc
close all
tic
%参数设定
M = 10;
DOA = [5 45 65]*pi/180;
SNR = 10;
sigma = 1/sqrt(SNR);		
d = 0.5;
N = 400;
QAM = 16;
P = length(DOA);
A=exp(-j*2*pi*0.5*[0:M-1]'*sin(DOA));
%信源模型建立
for k=1:P
    symbol = randi([0, QAM-1], 1, N);
    S(k,:) = qammod(symbol, QAM);
end


X = awgn(A*S,SNR,'measured');

S1=A(:,1)*A(:,1)';
S3=A(:,3)*A(:,3)';
n=normrnd(0,sigma,M,N);
Cov_n=zeros(M,M);
for m=1:N
    Cov_n=Cov_n+n(:,m)*n(:,m)';
end
Cov_n = Cov_n/N;
S_I = Cov_n+(S1+S3);


theta = 45*pi/180;
a0 = exp(-j*2*pi*d*[0:M-1]'*sin(theta));
a = a0/M;
w= inv(S_I)*a0/(a0'*inv(S_I)*a0);

SINR1 = 10*log10(abs((a'*a0*a0'*a)/(a'*S_I*a)))
SINR2 = 10*log10(abs((w'*a0*a0'*w)/(w'*S_I*w)))

toc
