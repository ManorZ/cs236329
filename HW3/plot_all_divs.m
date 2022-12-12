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
  face_vec_func(:,2:3) = 0; % (x,0,0)
  %face_vec_func(:,1) = 0; % (0,y,0)
  %face_vec_func(:,3) = 0;
  %face_vec_func(:,1:2) = 0; % (0,0,z)

  face_vec_func = reshape(face_vec_func, n_face*3, 1);

  face_div = face_div * face_vec_func;

  face_vec_func = reshape(face_vec_func, n_face, 3);

  options.vertex_color = face_div;
  plot_vector_field(vertex, face, face_center, face_vec_func, options);
  plot_title = base_file_name(1:end-4);
  title(plot_title);
  colorbar;

  save_name = sprintf('%s_div_face_center_x', base_file_name(1:end-4));
  %save_name = sprintf('%s_div_face_center_y', base_file_name(1:end-4));
  %save_name = sprintf('%s_div_face_center_z', base_file_name(1:end-4));

  save_name_png = fullfile('pngs/divs', sprintf('%s.png',save_name));
  save_name_fig = fullfile('figs/divs', sprintf('%s.fig',save_name));

  saveas(gcf, save_name_png);
  savefig(gcf, save_name_fig);

  close all;
  fprintf(1, 'done.\n');
end