function [x, y] = displacement(h0, a, v0, theta0, t)
% This function calculates the displacement in a plane (x,y), assuming a
% fixed accelaration.
% h0 = initial height
% a = acceleration
% v0 = initial velocity
% theta0 = initial angle with the ground in degrees
% t = time vector

x = v0*cos(theta0*pi/180)*t;
y = h0+v0*sin(theta0*pi/180)*t-0.5*a*t.^2;
end