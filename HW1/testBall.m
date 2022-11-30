v = 4;
a = 9.8;
h0 = 1.5;
thetas = 0:90;
figure;
D = [];
for i=1:length(thetas)
    d = throwBall4Q9(v, thetas(i), h0, a);
    D = [D,d];
end
plot(thetas, D);
title('Distance of ball throw as a function of release angle');
ylabel('Distance thrown (m)');
xlabel('Initial Angle (deg)');