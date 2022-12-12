clear; close all; clc;
file_names = dir(fullfile('hw2_data/*.off'));
for k = 1:length(file_names)
  base_file_name = file_names(k).name;
  full_file_name = fullfile('hw2_data', base_file_name);
  fprintf(1, 'reading %s ... ', full_file_name);
  
  [vertex, face] = read_mesh_off(full_file_name);

  if size(vertex, 1) > 20000
      fprintf(1, '|V|=%d ... skip\n', size(vertex, 1));
      continue
  end

  n_face = size(face, 1);
  n_vertex = size(vertex, 1);

  %const_func = ones(n_vertex, 1);
  const_func = (1:n_vertex)';
  cot_weight_mat = calc_cot_weight_mat(vertex, face);

  error = norm(cot_weight_mat * const_func);
  
  %fprintf(1, 'done. ||Wf|| = %f (f=ones())\n', error);
  fprintf(1, 'done. ||Wf|| = %f (f=1:|V|)\n', error);
end