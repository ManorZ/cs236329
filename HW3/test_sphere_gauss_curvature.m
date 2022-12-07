clear; close all; clc;
file_names = dir(fullfile('hw2_data/shpere*.off'));
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

  curvature = calc_gauss_curvature(vertex, face);
  
  curvature_error = mean(abs(ones(n_vertex, 1) - curvature));

  options.vertex_color = curvature;
  plot_triangle_3d_mesh(vertex, face, options);

  plot_title = sprintf('%s MAE %f', base_file_name(1:end-4), curvature_error);
  title(plot_title);
  colorbar;

  save_png_file = fullfile('pngs', sprintf('%s_gauss_curvature.png', base_file_name(1:end-4)));
  saveas(gcf, save_png_file);
  save_fig_file = fullfile('figs', sprintf('%s_gauss_curvature.fig', base_file_name(1:end-4)));
  savefig(gcf, save_fig_file);
  close all;
  fprintf(1, 'done.\n');
end