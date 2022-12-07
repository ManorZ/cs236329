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

  face_div = calc_div(vertex, face);
  
  face_center = calc_face_center(vertex, face);

  face_vec_func = face_center;
  face_vec_func(:,2:3) = 0;
  face_vec_func(:,1) = face_vec_func(:,1) * 2;

  face_vec_func = reshape(face_vec_func, n_face*3, 1);

  face_div = face_div * face_vec_func;

  face_vec_func = reshape(face_vec_func, n_face, 3);

  options.vertex_color = face_div;
  plot_vector_field(vertex, face, face_center, face_vec_func, options);
  plot_title = base_file_name(1:end-4);
  title(plot_title);
  colorbar;
  save_png_file = fullfile('pngs', sprintf('%s_face_center_x_div.png', base_file_name(1:end-4)));
  saveas(gcf, save_png_file);
  save_fig_file = fullfile('figs', sprintf('%s_face_center_x_div.fig', base_file_name(1:end-4)));
  savefig(gcf, save_fig_file);
  close all;
  fprintf(1, 'done.\n');
end