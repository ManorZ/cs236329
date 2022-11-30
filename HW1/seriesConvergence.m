close all
clear
clc
%b
p = 0.99;
k = 0:1000;
%c
geomSeries = p.^k;
%d
G = 1/(1-p);
%e
figure;
plot(k, zeros(1,length(k))+G, 'r');
hold on;
%f
plot(k, cumsum(geomSeries), 'b');
xlabel('Index');
ylabel('Sum');
title('Convergence of geometric series with p=0.99');
legend('Infinite Sum', 'finite Sum');
%h
p = 2;
n = 1:500;
pSeries = 1./(n.^p);
%i
P = (pi^2)/6;
%m
figure;
plot(n, zeros(1,length(n))+P, 'r');
hold on;
plot(n, cumsum(pSeries), 'b');
xlabel('Index');
ylabel('Sum');
title('Convergence of p-series with p=2');
legend('Infinite Sum', 'finite Sum');

