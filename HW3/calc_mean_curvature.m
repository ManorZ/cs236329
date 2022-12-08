function curvature = calc_mean_curvature(vertex, face)
lap = calc_lap_beltrami(vertex, face, vertex);
vertex_normal = calc_vertex_normal(vertex, face);
%vertex_normal = vertex_normal ./ sqrt(sum(vertex_normal.^2,2));
%curvature = sqrt(sum(lap.^2,2))/2;
curvature = sum(lap .* vertex_normal,2)/2;
end