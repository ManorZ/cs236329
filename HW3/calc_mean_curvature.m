function curvature = calc_mean_curvature(vertex, face)
lap = calc_lap_beltrami(vertex, face, vertex);
curvature = sqrt(sum(lap.^2,2))/2;
end