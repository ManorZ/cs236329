clear
clc
%Q1
a = 10;
b = 2.5*10^23;
c = 2+3*i;
d = exp((2/3)*pi*i);
%Q2
aVec = [3.14, 15, 9, 26];
bVec = [2.71; 8; 28; 182];
cVec = 5:-0.2:-5;
dVec = logspace(0,1, 101);
eVec = 'Hello';
%Q3
aMat = ones(9)*2;
bMat = diag([1:4,5,4:-1:1]);
cMat = reshape(1:100,10,10);
dMat = nan(3,4);
eMat = [13, -1, 5; -22, 10, -87];
fMat = randi([-3, 3], 5, 3);
%Q4
x = 1/(1+exp(-(a-15)/6))
y = (a^(1/21) + b^(1/21))^pi
z = log(real((c+d)*(c-d))*sin(a*pi/3))/(c*conj(c))
%Q5
xMat = (aVec*bVec)*aMat^2
yMat = bVec*aVec
zMat = det(cMat)*(aMat*bMat)'
%Q6
cSum = sum(cMat);
eMean = mean(eMat,2);
eMat(1,:) = [1, 1, 1];
cSub = cMat(2:9,2:9);
lin = 1:20;
lin(mod(lin,2)==0) = -lin(mod(lin,2)==0);
r = rand(1,5);
%r(find(r<0.5)) = 0;
r(r<0.5) = 0;

