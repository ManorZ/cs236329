close all; clc;
file_names = dir(fullfile('hw2_data/*.off'));
for k = 1:length(file_names)
  base_file_name = file_names(k).name;
  full_file_name = fullfile('hw2_data', base_file_name);
  fprintf(1, 'reading %s ... \n', full_file_name);
  
  [vertex, face] = read_mesh_off(full_file_name);
  face_center = calc_face_center(vertex, face);
  [face_normal, face_area] = calc_face_normal(vertex, face);
  
  options.face_color = face_area;
  plot_vector_field(vertex, face, face_center, face_normal, options);
  plot_title = base_file_name(1:end-4);
  title(plot_title);
  colorbar;
  save_png_file = fullfile('pngs', sprintf('%s_face_normal.png', base_file_name(1:end-4)));
  saveas(gcf, save_png_file);
  save_fig_file = fullfile('figs', sprintf('%s_face_normal.fig', base_file_name(1:end-4)));
  savefig(gcf, save_fig_file);
  close all;
end