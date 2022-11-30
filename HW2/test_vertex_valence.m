function test_vertex_valence(dir_name)
close all; clc;
file_names = dir(fullfile(dir_name,'*.off'));
for k = 1:length(file_names)
  base_file_name = file_names(k).name;
  full_file_name = fullfile(dir_name, base_file_name);
  fprintf(1, 'reading %s ... ', full_file_name);
  [vertex, face] = read_mesh_off(full_file_name);
  vertex_valence = calc_valence(vertex, face);
  average_valence = mean(vertex_valence);
  fprintf('average valence: %f\n', average_valence);
end

end