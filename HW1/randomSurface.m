close all
clear
clc
Z0 = rand(5);
x0 = 1:5;
y0 = x0;
[X0, Y0] = meshgrid(x0,y0);
x1 = 1:0.1:5;
y1 = x1;
[X1, Y1] = meshgrid(x1,y1);
Z1 = interp2(X0, Y0, Z0, X1, Y1, 'cubic');
figure;
surf(X1, Y1, Z1);
colormap("hsv");
shading interp;
hold on;
contour(X1, Y1, Z1, 15);
colorbar()