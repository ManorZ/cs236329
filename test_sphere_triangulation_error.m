function test_sphere_triangulation_error(dir_name)
close all; clc;
file_names = dir(fullfile(dir_name,'sphere*.off'));
error = [];
X = [];
for k = 1:length(file_names)
  base_file_name = file_names(k).name;
  full_file_name = fullfile(dir_name, base_file_name);
  fprintf(1, 'reading %s\n', full_file_name);
  [vertex, face] = read_mesh_off(full_file_name);
  e = sphere_triangulation_error(vertex, face);
  error = [error, e];
  edge_length = calc_edge_length(vertex, face);
  x = mean(edge_length, 'all');
  X = [X, x];
end
figure()
plot(X, error, 'o-', 'Color', 'b')
grid on;
xlabel('Average Edge Length');
ylabel('Triangulation Error');
title('Trianfulation Error vs. Average Length for Unit Mesh Sphere');
saveas(gcf, 'sphere_triangulation_error.png');
end