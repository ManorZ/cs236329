function smoothed = nonUniformRectFilterWithInterp(xy, width)
x = xy(:, 1);
y = xy(:, 2);
x1 = linspace(min(x), max(x), 100)';
%x1 = [x; x1];
%sort(x1);
%unique(x1);
y1 = interp1(x, y, x1);
disc_width = floor(width/(x1(2)-x1(1)))
y1 = [ones(1, floor(disc_width/2))'*y1(1); y1; ones(1, floor(disc_width/2))'*y1(length(y1))];
filter = ones(disc_width,1)*1/disc_width
y2 = conv(y1, filter, "same");
y2 = y2(floor(disc_width/2)+1:length(y1)-floor(disc_width/2));
smoothed = [x1,y2];
end