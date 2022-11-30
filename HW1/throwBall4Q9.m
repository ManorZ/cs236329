function distance=throwBall4Q9(v0, theta0, h0, a)
t = linspace(0,10,1000);
x = v0*cos(theta0*pi/180)*t;
y = h0+v0*sin(theta0*pi/180)*t-0.5*a*t.^2;
if y(length(y))>0
    fprintf('The ball does not hit the ground in 10 seconds');
    distance = nan;
else
    ground_touchdown_index = find(y <= 0);
    ground_touchdown_index = ground_touchdown_index(1);
    horizontal_displacement = x(ground_touchdown_index);
    distance = horizontal_displacement;
end
end