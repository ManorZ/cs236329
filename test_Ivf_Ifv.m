function test_Ivf_Ifv(dir_name)
close all; clc;
file_names = dir(fullfile(dir_name,'oloid3.off'));

animation_mode = true;

for k = 1:length(file_names)
  base_file_name = file_names(k).name;
  full_file_name = fullfile(dir_name, base_file_name);
  fprintf(1, 'reading %s ... ', full_file_name);
  [vertex, face] = read_mesh_off(full_file_name);

  face_color = zeros(size(face, 1), 1);
  face_color(100) = 1;
  
  n_iterations = 400;

  figure();
  options.face_color = face_color;
  if ~animation_mode
      subplot_x = 4;
      subplot_y = 4;
      plot_every = floor(n_iterations / (subplot_x * subplot_y));
      subplot(subplot_x,subplot_y,1);
  end
  title(1);
  patch = plot_triangle_3d_mesh(vertex, face, options);
  grid on;
  hold on;

  if animation_mode
      view(3,3);
      %view(0,90);
      axis tight;
      colorbar east
      animation_filename = sprintf('%s_Ivf_Ifv_animation.gif', base_file_name(1:end-4));
      frame = getframe(gcf);
      im = frame2im(frame);
      [imind,cm] = rgb2ind(im,256);
      imwrite(imind, cm, animation_filename, 'gif', 'Loopcount', inf,'DelayTime', 0.1);
  end

  Ivf = create_Ivf(vertex, face);
  Ifv = create_Ifv(vertex, face);
  
  prev_face_color = face_color;
  
  face_color_error = [];
  face_color_sum = sum(face_color);
  for i = 2 : n_iterations
      fprintf(1, '%d ', i);

      vertex_color = Ivf * face_color;
      face_color = Ifv * vertex_color;
      face_color_sum = [face_color_sum, sum(face_color)];
      
      face_color_error = [face_color_error, mean(abs(face_color - prev_face_color))];
      prev_face_color = face_color;
      
      if ~animation_mode
          if mod(i, plot_every) == 0
              options.face_color = face_color;
              try
                  subplot(subplot_x,subplot_y,i/plot_every+1);
              catch e
                  fprintf(1,'\nError!\n%s',e.message);
              end
              title(i);
              patch = plot_triangle_3d_mesh(vertex, face, options);
              grid on;
              hold on;
          end
      else
          title(i);
          patch.FaceVertexCData = face_color;
          view(3*i,3);
          %view(0,90);
          frame = getframe(gcf);
          im = frame2im(frame);
          [imind,cm] = rgb2ind(im,256);
          imwrite(imind,cm,animation_filename,'gif','WriteMode','append','DelayTime',0.1);
      end
  end
  fprintf(1, '\n');

  figure();
  plot(1:n_iterations-1, face_color_error, '-.');
  grid on
  title('Face Color Consecutive Error')
  saveas(gcf, sprintf('%s_Ivf_Ifv_face_color_consecutive_error.png', base_file_name(1:end-4)));

  figure();
  plot(1:n_iterations, face_color_sum, '-.');
  grid on
  title('Face Color Sum')
  saveas(gcf, sprintf('%s_Ivf_Ifv_face_color_sum.png', base_file_name(1:end-4)));

end
end