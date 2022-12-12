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

  cot_weight_mat = calc_cot_weight_mat(vertex, face);

  n_weights = length(nonzeros(cot_weight_mat));
  
  fprintf(1, "done. n_weights = %d\t n_vertex = %d\t ratio = %f\n", n_weights, n_vertex, n_weights/n_vertex);
end