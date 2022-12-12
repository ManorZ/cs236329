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

  %vertex_sca_func = vertex(:,3);
  %vertex_sca_func = vertex(:,2);
  %vertex_sca_func = vertex(:,1);
  vertex_sca_func = calc_vertex_barycentric_cell_area(vertex, face);

  face_center = calc_face_center(vertex, face);
  
  face_grad = calc_grad(vertex, face);
  face_lap = calc_lap(vertex, face);
  
  face_grad = face_grad * vertex_sca_func;
  face_lap = face_lap * vertex_sca_func;

  face_grad = reshape(face_grad, n_face, 3);

  options.vertex_color = face_lap;
  plot_vector_field(vertex, face, face_center, face_grad, options);

  plot_title = base_file_name(1:end-4);
  title(plot_title);
  colorbar;

  %save_name = sprintf('%s_lap_z', base_file_name(1:end-4));
  %save_name = sprintf('%s_lap_y', base_file_name(1:end-4));
  %save_name = sprintf('%s_lap_x', base_file_name(1:end-4));
  save_name = sprintf('%s_lap_bary_area', base_file_name(1:end-4));

  save_name_png = fullfile('pngs/laps', sprintf('%s.png',save_name));
  save_name_fig = fullfile('figs/laps', sprintf('%s.fig',save_name));

  saveas(gcf, save_name_png);
  savefig(gcf, save_name_fig);

  close all;
  fprintf(1, 'done.\n');
end