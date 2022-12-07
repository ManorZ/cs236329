function debug_plot(vertex, face, j)
    
    this_face = face(j,:);
    
    plot_triangle_3d_mesh(vertex, this_face);
    hold on; grid on; xlabel('x');ylabel('y');zlabel('z');
    
    v1 = vertex(this_face(1), :);
    v2 = vertex(this_face(2), :);
    v3 = vertex(this_face(3), :);
    
    scatter3(v1(j,1),v1(j,2),v1(j,3));
    text(v1(j,1),v1(j,2),v1(j,3), sprintf('v1: %d', this_face(1)));

    scatter3(v2(j,1),v2(j,2),v2(j,3));
    text(v2(j,1),v2(j,2),v2(j,3), sprintf('v2: %d', this_face(2)));

    scatter3(v3(j,1),v3(j,2),v3(j,3));
    text(v3(j,1),v3(j,2),v3(j,3), sprintf('v3: %d', this_face(3)));

    e1 = v2 - v3;
    e2 = v3 - v1;
    e3 = v1 - v2;

    quiver3(v3(j,1),v3(j,2),v3(j,3), e1(j,1),e1(j,2),e1(j,3),0);
    text((v3(j,1)+v2(j,1))/2,(v3(j,2)+v2(j,2))/2,(v3(j,3)+v2(j,3))/2, sprintf('e1: %d->%d', this_face(3), this_face(2)));

    quiver3(v1(j,1),v1(j,2),v1(j,3), e2(j,1),e2(j,2),e2(j,3),0);
    text((v3(j,1)+v1(j,1))/2,(v3(j,2)+v1(j,2))/2,(v3(j,3)+v1(j,3))/2, sprintf('e2: %d->%d', this_face(1), this_face(3)));

    quiver3(v2(j,1),v2(j,2),v2(j,3), e3(j,1),e3(j,2),e3(j,3),0);
    text((v1(j,1)+v2(j,1))/2,(v1(j,2)+v2(j,2))/2,(v1(j,3)+v2(j,3))/2, sprintf('e3: %d->%d', this_face(2), this_face(1)));

    c = calc_face_center(vertex, this_face);
    [u, ~] = calc_face_normal(vertex, this_face);

    quiver3(c(1),c(2),c(3), u(1),u(2),u(3),0);
    scatter3(c(1),c(2),c(3));
    text(c(1),c(2),c(3), 'u');

    %quiver3(v3(j,1),v3(j,2),v3(j,3), Je1(1),Je1(2),Je1(3),0);
    %quiver3(v1(j,1),v1(j,2),v1(j,3), Je2(1),Je2(2),Je2(3),0);
    %quiver3(v2(j,1),v2(j,2),v2(j,3), Je3(1),Je3(2),Je3(3),0);
end