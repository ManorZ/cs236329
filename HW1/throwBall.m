clear
clc
%b
init_release_height = 1.5; % initial height of ball at release [m]
g = 9.8; % gravitational acceleration [m/s^2]
init_release_velocity = 4; % velocity of ball at release [m/s]
init_release_velocity_angle = 45; % angle of the velocity vector at time of release [degrees]
%c
t = linspace(0, 1, 1000);
%d
[x,y] = displacement(init_release_height, g, init_release_velocity, init_release_velocity_angle, t);
%e
ground_touchdown_index = find(y <= 0);
ground_touchdown_index = ground_touchdown_index(1);
horizontal_displacement = x(ground_touchdown_index);
fprintf('The ball hits the ground at a distance of %d meters.\n', horizontal_displacement);
%f
figure;
plot(x, y);
xlabel('X [m]');
ylabel('Y [m]');
title('X-Y Displacement');
hold on;
x_ground = linspace(min(x), max(x), length(x));
y_ground = zeros(1, length(x_ground));
plot(x_ground, y_ground, '--');
legend('X-Y Displacement', 'Ground');

%g (my bonus :-))
figure;
plot(t, x);
hold on;
plot(t, y);
xlabel('T [s]');
ylabel('Displacement [m]');
title('X-Y Displacement vs. Time');
legend('X Displacement', 'Y Displacement');

