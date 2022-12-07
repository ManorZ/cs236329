clear; close all; clc;
file_names = dir(fullfile('hw2_data/*.off'));
for k = 1:length(file_names)
  base_file_name = file_names(k).name;
  full_file_name = fullfile('hw2_data', base_file_name);
  fprintf(1, 'reading %s ... ', full_file_name);
  
  [vertex, face] = read_mesh_off(full_file_name);

  if size(vertex, 1) > 10000
      fprintf(1, '|V|=%d ... skip\n', size(vertex, 1));
      continue
  end

  n_face = size(face, 1);
  n_vertex = size(vertex, 1);

  face_center = calc_face_center(vertex, face);

  vertex_func = (1:length(vertex))' * 2;
  
  fprintf(1, 'calc lap ... ');
  face_lap = calc_lap(vertex, face) * vertex_func;

  fprintf(1, 'calc lap beltrami ... ');
  face_lap_beltrami = calc_lap_beltrami(vertex, face, vertex_func);

  lap_beltrami_error = norm(face_lap - face_lap_beltrami);
  
  fprintf(1, 'done. ||Laplacian(F) - Laplacian-Beltrami(F)||^2 = %f\n', lap_beltrami_error);
end