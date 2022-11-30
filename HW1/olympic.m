close all
clear
clc
figure;
r = 0.45
centers = [-1, 0; -0.5, -0.5; 0, 0; 0.5, -0.5; 1, 0]
colors = ['b', 'y', 'k', 'g', 'r']
for i=1:5
    
    [x,y] = getCircle(centers(i,:), r);
    plot(x, y, LineWidth=4, Color=colors(i));
    hold on;
    i = i+1
end
