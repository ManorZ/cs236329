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

  cot_weight_mat = calc_cot_weight_mat(vertex, face);

  fprintf(1, "calc cot weight matrix ... ");
  [B500, D500] = calc_cot_weight_mat_smooth_basis(vertex, face, min(n_vertex,500), 'sm');
  %[B500, D500] = calc_cot_weight_mat_smooth_basis(vertex, face, min(n_vertex,500), 'lm');

  for k = 1:9
    Bk = B500(:,k);
    subplot(3,3,k);
    options.vertex_color = real(Bk);
    plot_triangle_3d_mesh(vertex, face, options);
    colorbar;
    title(sprintf('B%d', k))
  end

  save_fig_file = fullfile('cotangent_weight_matrix', sprintf('%s_9_smallest_eigenvectors.fig', base_file_name(1:end-4)));
  savefig(gcf, save_fig_file);

  
  %f = zeros(n_vertex, 1);
  %f(42) = 1;
  [f, ~] = eigs(calc_cot_weight_mat(vertex, face), 1);
  
  K = 10:10:min(n_vertex,500);
  N = [];
  fprintf(1, "calc proj errors ... ");
  for k = 1:length(K)
      fprintf(1, "%d, ", K(k));
      Bk = B500(:,1:K(k));
      gk = Bk * Bk' * f;
      n = norm(gk-f);
      N = [N;n];
  end
  
  figure();

  subplot(1,2,1);
  options.vertex_color = f;
  plot_triangle_3d_mesh(vertex, face, options);
  plot_title = 'f';
  title(plot_title);
  colorbar;

  subplot(1,2,2);
  options.vertex_color = gk;
  plot_triangle_3d_mesh(vertex, face, options);
  plot_title = sprintf('g%d', K(k));
  title(plot_title);
  colorbar;
  
  sgtitle(sprintf('Original Function vs. Projected Onto B%d and Back', K(k)));

  %save_name = sprintf('%s_pulse_function_reduced_basis', base_file_name(1:end-4));
  %save_name = sprintf('%s_pulse_function_reduced_basis_largest_eigs', base_file_name(1:end-4));
  save_name = sprintf('%s_largest_eigvec_reduced_basis', base_file_name(1:end-4));

  save_name_fig = fullfile('cotangent_weight_matrix', sprintf('%s.fig',save_name));
  savefig(gcf, save_name_fig);

  figure();
  plot(K, N, '-.');
  grid on
  xlabel('K');
  ylabel('||f-gk||');
  title('Projection and Back error')

  %save_name = sprintf('%s_pulse_function_reduced_basis_projection_error', base_file_name(1:end-4));
  %save_name = sprintf('%s_pulse_function_reduced_basis_projection_error_largest_eigs', base_file_name(1:end-4));
  save_name = sprintf('%s_largest_eigvec_reduced_basis_projection_error', base_file_name(1:end-4));
  
  save_name_fig = fullfile('cotangent_weight_matrix', sprintf('%s.fig',save_name));
  savefig(gcf, save_name_fig);

  close all;

  fprintf(1, "done.\n");
end