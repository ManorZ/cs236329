function Ylm = calc_spherical_harmonic(theta, phi, m, l)
Ylm = sqrt((2*l+1)/(4*pi)*(factorial(l-m)/factorial(l+m)))*legendre(l, cos(theta))';
Ylm = Ylm(:, m+1);
end