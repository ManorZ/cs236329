clear
clc
figure
t = linspace(0,2*pi, 100);
sint = sin(t);
plot(t,sint, 'b');
hold on;
cost = cos(t);
plot(t, cost, 'r');
xlabel('Time (s)');
ylabel('Function value');
title('Sin and Cosin functions');
legend('Sin', 'Cos');
xlim([0,2*pi]);
ylim([-1.4,1.4]);