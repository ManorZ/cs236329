close all
clear
clc
%2.1
students_count = [15, 25, 55, 115, 144, 242];
figure;
semilogy(1:length(students_count), students_count, 'ms', 'MarkerSize', 10, 'LineWidth', 4);
xlabel('index');
ylabel('students count');
title('6.057 student count over the past 6 years');
%xlim([0, 7]);
%ylim([0, 300]);
%2.2
figure
load('hw1_2/MIT6_057IAP19_hw2/mitMap.mat');
subplot(2, 2, 1)
imagesc(mit);
colormap(cMap);
axis square;
title('square');
subplot(2, 2, 2)
imagesc(mit);
colormap(cMap);
axis tight;
title('tight');
subplot(2, 2, 3)
imagesc(mit);
colormap(cMap);
axis equal;
title('equal');
subplot(2, 2, 4)
imagesc(mit);
colormap(cMap);
axis xy
title('xy');
%2.3
values = rand(1, 5);
values = sort(values);
figure;
bar(values, 'r');
title('Bar Graph of 5 Random Values');
