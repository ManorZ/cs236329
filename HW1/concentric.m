close all
clear
clc
figure;
axis equal;
radii = [1, 2, 3, 4, 5];
jet=colormap("jet");
i = 1;
for r=radii
    [x,y] = getCircle([0, 0], r);
    plot(x, y, LineWidth=4, Color=jet(i,:));
    hold on;
    i = i+floor(length(jet)/length(radii))
end

