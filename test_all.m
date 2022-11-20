function test_all(dir_name)
close all; clc;
file_names = dir(fullfile(dir_name,'*.off'));
for k = 1:length(file_names)
  base_file_name = file_names(k).name;
  full_file_name = fullfile(dir_name, base_file_name);
  fprintf(1, 'reading %s\n', full_file_name);
  [vertex, face] = read_mesh_off(full_file_name);
  face_area = calc_face_area(vertex, face);
  options.face_color = face_area;
  figure();
  title(base_file_name);
  plot_triangle_3d_mesh(vertex, face, options);
  calc_genus(vertex, face);
  %compute_boundary(face);
end
end