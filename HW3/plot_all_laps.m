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

  vertex_area = calc_vertex_barycentric_cell_area(vertex, face);
  face_center = calc_face_center(vertex, face);
  
  face_grad = calc_grad(vertex, face);
  face_lap = calc_lap(vertex, face);
  
  face_grad = face_grad * vertex_area;
  face_lap = face_lap * vertex_area;

  face_grad = reshape(face_grad, n_face, 3);

  options.vertex_color = face_lap;
  plot_vector_field(vertex, face, face_center, face_grad, options);

  plot_title = base_file_name(1:end-4);
  title(plot_title);
  colorbar;
  save_png_file = fullfile('pngs', sprintf('%s_bary_area_lap.png', base_file_name(1:end-4)));
  saveas(gcf, save_png_file);
  save_fig_file = fullfile('figs', sprintf('%s_bary_area_lap.fig', base_file_name(1:end-4)));
  savefig(gcf, save_fig_file);
  close all;
  fprintf(1, 'done.\n');
end