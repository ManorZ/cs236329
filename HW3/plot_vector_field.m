function plot_vector_field(vertex, face, vec_origin, vec, options)
if size(vertex, 1) ~= size(vec, 1) && size(face, 1) ~= size(vec, 1)
    error('#vector mismatch with #vertex/#face');
end
options.nan = nan;
plot_triangle_3d_mesh(vertex, face, options);
hold on;
quiver3(vec_origin(:, 1), vec_origin(:, 2), vec_origin(:, 3), vec(:, 1), vec(:, 2), vec(:, 3));
end