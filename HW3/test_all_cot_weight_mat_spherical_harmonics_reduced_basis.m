clear; close all; clc;
file_names = dir(fullfile('hw2_data/sphere_s*.off'));
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

  cot_weight_mat = calc_cot_weight_mat(vertex, face);

  fprintf(1, "calc cot weight matrix ... ");
  [B9, ~] = calc_cot_weight_mat_smooth_basis(vertex, face, 9, 'sm');

  for k = 1:9
    Bk = B9(:,k);
    subplot(3,3,k);
    options.vertex_color = real(Bk);
    plot_triangle_3d_mesh(vertex, face, options);
    colorbar;
    title(sprintf('B%d', k))
  end
  save_fig_file = fullfile('cotangent_weight_matrix', sprintf('%s_eigenvectors.fig', base_file_name(1:end-4)));
  savefig(gcf, save_fig_file);

  [az,el,~] = cart2sph(vertex(:,1), vertex(:,2), vertex(:,3));

  figure;
  i = 1;
  for l = 0:3
      for m = 0:l
          Yml = calc_spherical_harmonic(az, el, m,l);
          subplot(3,3,i);
          i = i+1;
          options.vertex_color = Yml;
          plot_triangle_3d_mesh(vertex, face, options);
          colorbar;
          title(sprintf('Y^%d_%d', m,l));
          if i > 9
              break
          end
      end
      if i > 9
          break
      end
  end
  save_fig_file = fullfile('cotangent_weight_matrix', sprintf('%s_spherical_harmonics.fig', base_file_name(1:end-4)));
  savefig(gcf, save_fig_file);
  
  close all;

  fprintf(1, "done.\n");
end