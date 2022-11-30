function smoothed = rectFilter(x, width)
if mod(width,2) == 0
    fprintf("width (=%d) is not odd", width);
    width = width+1;
end
filter = ones(1,width)/width;
%smoothed = conv(x, filter, "same");
%smoothed = smoothed(floor(width/2)+1:length(x)-floor(width/2));
%smoothed = [x(1:floor(width/2)), smoothed, x(length(x)-floor(width/2)+1:length(x))];
x_w_dup_pad = [ones(1, floor(width/2))*x(1), x, ones(1, floor(width/2))*x(length(x))];
smoothed = conv(x_w_dup_pad, filter, "same");
smoothed = smoothed(floor(width/2)+1:length(x)-floor(width/2));
end