function test_linear_op_kernel(dir_name)
close all; clc;
file_names = dir(fullfile(dir_name,'*.off'));
for k = 1:length(file_names)
  base_file_name = file_names(k).name;
  full_file_name = fullfile(dir_name, base_file_name);
  fprintf(1, 'reading %s ... ', full_file_name);
  [vertex, face] = read_mesh_off(full_file_name);

  if size(vertex, 1) > 1000
      fprintf(1, '|V|=%d ... skip\n', size(vertex, 1));
      continue
  end
  
  fprintf(1, 'calc Ivf ... ');
  Ivf = create_Ivf(vertex, face);
  fprintf(1, 'calc kernel ... ');
  Ivf_kernel = calc_linear_op_kernel(Ivf);
  fprintf('Ivf Kernel Size (Null Space): %d\t', size(Ivf_kernel, 2));

  fprintf(1, 'calc Ifv ... ');
  Ifv = create_Ifv(vertex, face);
  fprintf(1, 'calc kernel ... ');
  Ifv_kernel = calc_linear_op_kernel(Ifv);
  fprintf('Ifv Kernel Size: %d\n', size(Ifv_kernel, 2));
end
end