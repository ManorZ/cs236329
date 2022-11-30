function [x,y] = getCircle(center,r)
t = linspace(0, 2*pi, 360);
x = center(1)+r*cos(t);
y = center(2)+r*sin(t);
end