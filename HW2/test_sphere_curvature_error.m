function [outputArg1,outputArg2] = test_sphere_curvature_error(dir_name)
close all; clc;
file_names = dir(fullfile(dir_name,'sphere*.off'));
cmean_error1 = [];
cmean_error2 = [];
cgauss_error1 = [];
cgauss_error2 = [];
X = [];
for k = 1:length(file_names)
  base_file_name = file_names(k).name;
  full_file_name = fullfile(dir_name, base_file_name);
  fprintf(1, 'reading %s\n', full_file_name);
  [vertex, face] = read_mesh_off(full_file_name);
  options.nan = nan;
  [Umin,Umax,Cmin,Cmax,Cmean,Cgauss,Normal] = compute_curvature(vertex,face,options);
  
  cmean_e1 = mean(abs(Cmean - 1)); % unit sphere curvature is 1 everywhere
  cmean_e2 = abs(sum(Cmean) - 4*pi);
  sum(Cmean)
  
  cgauss_e1 = mean(abs(Cgauss - 1));
  cgauss_e2 = abs(sum(Cgauss) - 4*pi);
  sum(Cgauss)
  
  cmean_error1 = [cmean_error1, cmean_e1];
  cmean_error2 = [cmean_error2, cmean_e2];

  cgauss_error1 = [cgauss_error1, cgauss_e1];
  cgauss_error2 = [cgauss_error2, cgauss_e2];

  edge_length = calc_edge_length(vertex, face);
  x = mean(edge_length, 'all');
  X = [X, x];
end
figure();
plot(X, cmean_error1, 'o-', 'Color', 'b');
grid on;
xlabel('Average Edge Length');
ylabel('Curvature Error');
title('Sum of Per-Vertex Mean Curvature Error vs. Average Length for Unit Mesh Sphere')
savefig('per_vertex_mean_curvature_error.fig')

figure();
plot(X, cgauss_error1, 'o-', 'Color', 'b');
grid on;
xlabel('Average Edge Length');
ylabel('Curvature Error');
title('Sum of Per-Vertex Gauss Curvature Error vs. Average Length for Unit Mesh Sphere')
savefig('per_vertex_gauss_curvature_error.fig')

figure();
plot(X, cmean_error2, 'o-', 'Color', 'r');
grid on;
xlabel('Average Edge Length');
ylabel('Curvature Error');
title('Gauss-Bonnet Mean Curvature Error vs. Average Length for Unit Mesh Sphere')
savefig('gauss-bonnet_mean_curvature_error.fig')

figure();
plot(X, cgauss_error2, 'o-', 'Color', 'r');
grid on;
xlabel('Average Edge Length');
ylabel('Curvature Error');
title('Gauss-Bonnet Gauss Curvature Error vs. Average Length for Unit Mesh Sphere')
savefig('gauss-bonnet_gauss_curvature_error.fig')
end