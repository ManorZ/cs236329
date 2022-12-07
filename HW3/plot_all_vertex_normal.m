close all; clc;
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

  face_center = calc_face_center(vertex, face);
  [face_normal, face_area] = calc_face_normal(vertex, face);
  vertex_normal = calc_vertex_normal(vertex, face);
  
  subplot(1,2,1);
  options.face_color = face_area;
  plot_vector_field(vertex, face, face_center, face_normal, options);
  plot_title = sprintf('%s face normal', base_file_name(1:end-4));
  title(plot_title);
  colorbar;

  subplot(1,2,2);
  options.face_color = face_area;
  plot_vector_field(vertex, face, vertex, vertex_normal, options);
  plot_title = sprintf('%s vertex normal', base_file_name(1:end-4));
  title(plot_title);
  colorbar;

  save_png_file = fullfile('pngs', sprintf('%s_vertex_normal.png', base_file_name(1:end-4)));
  saveas(gcf, save_png_file);
  save_fig_file = fullfile('figs', sprintf('%s_vertex_normal.fig', base_file_name(1:end-4)));
  savefig(gcf, save_fig_file);
  close all;
  fprintf(1, 'done.\n');
end