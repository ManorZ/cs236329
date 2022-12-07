function R = create_R(u, theta)
% https://en.wikipedia.org/wiki/Rotation_matrix#General_rotations
if size(u) ~= [1,3]
    error('vectorized rotation matrix is not supported yet');
end

ux = u(1);
uy = u(2);
uz = u(3);

R = [
    cos(theta)+ux^2*(1-cos(theta)),     ux*uy*(1-cos(theta))-uz*sin(theta), ux*uz*(1-cos(theta))+uy*sin(theta);
    uy*ux*(1-cos(theta))+uz*sin(theta), cos(theta)+uy^2*(1-cos(theta)),     uy*uz*(1-cos(theta))-ux*sin(theta);
    uz*ux*(1-cos(theta))-uy*sin(theta), uz*uy*(1-cos(theta))+ux*sin(theta), cos(theta)+uz^2*(1-cos(theta))
    ];
end