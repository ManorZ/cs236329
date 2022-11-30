function ind = findNearest(x, desiredVal)
abs_dist = abs(x - desiredVal);
min_dist = min(abs_dist(:));
min_ind = find(abs_dist == min_dist);
%nearest = x(min_ind)
ind = min_ind;
end