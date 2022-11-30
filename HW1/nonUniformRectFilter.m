function smoothed = nonUniformRectFilter(xy, width)
x = xy(:, 1);
y = xy(:, 2);
left_edge = x(1);
right_edge = x(length(x));
filter_range = [left_edge+width/2, right_edge-width/2];
x_wo_edge = x(x>filter_range(1));
x_wo_edge = x_wo_edge(x_wo_edge<filter_range(2));
i = 1;
smoothed_y = [];
for i=1:length(x_wo_edge)
    point_boundaries = [x_wo_edge(i)-width/2, x_wo_edge(i)+width/2];
    point_values = y(x>point_boundaries(1) & x<point_boundaries(2));
    smoothed_point = mean(point_values);
    smoothed_y = [smoothed_y; smoothed_point];
    i = i+1;
end
smoothed_y = [y(x<filter_range(1)); smoothed_y; y(x>filter_range(2))];
smoothed = [x, smoothed_y];
end