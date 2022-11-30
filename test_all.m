function test_all(dir_name)
close all; clc;
file_names = dir(fullfile(dir_name,'*.off'));
for k = 1:length(file_names)
  base_file_name = file_names(k).name;
  full_file_name = fullfile(dir_name, base_file_name);
  fprintf(1, 'reading %s\n', full_file_name);
  [vertex, face] = read_mesh_off(full_file_name);
  face_area = calc_face_area(vertex, face);
  
  genus = calc_genus(vertex, face);
  boundary_edge = calc_boundary_edge(vertex, face);
  n_boundary_edge = length(boundary_edge) / 2

  figure();
  options.face_color = face_area;
  plot_triangle_3d_mesh(vertex, face, options);
  title_name = sprintf('%s - genus: %d - %d boundary edges', base_file_name(1:end-4), genus, n_boundary_edge);
  title(title_name);
  file_name = sprintf('%s_genus_and_boundary_edge.png', base_file_name(1:end-4));
  saveas(gcf, file_name);
end
end