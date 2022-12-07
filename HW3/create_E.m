function E = create_E(vertex, face)
n_vertex = size(vertex, 1);
n_face = size(face, 1);

E = sparse(3 * n_face, n_vertex);
face_set = create_face_set(vertex, face);

v1 = squeeze(face_set(:,1,:));
v2 = squeeze(face_set(:,2,:));
v3 = squeeze(face_set(:,3,:));

%e1 = v3 - v2;
%e2 = v1 - v3;
%e3 = v2 - v1;

e1 = v2 - v3;
e2 = v3 - v1;
e3 = v1 - v2;

[u, ~] = calc_face_normal(vertex, face);
%face_center = calc_face_center(vertex, face);

u = u ./ sqrt(sum(u.^2, 2));

% TODO: vectorize!
for j = 1 : size(u, 1)
    
    R = create_R(u(j,:), pi/2);
    Je1 = e1(j,:) * R;
    Je2 = e2(j,:) * R;
    Je3 = e3(j,:) * R;
    Je = [Je1; Je2; Je3];

    E(j+0*n_face, face(j,:)) = Je(:,1);
    E(j+1*n_face, face(j,:)) = Je(:,2);
    E(j+2*n_face, face(j,:)) = Je(:,3);

    %plot_triangle_3d_mesh(vertex, face(j,:));
    %hold on; grid on; xlabel('x');ylabel('y');zlabel('z');
    %scatter3(v1(j,1),v1(j,2),v1(j,3));
    %scatter3(v2(j,1),v2(j,2),v2(j,3));
    %scatter3(v3(j,1),v3(j,2),v3(j,3));
    %text(v1(j,1),v1(j,2),v1(j,3),'v1');
    %text(v2(j,1),v2(j,2),v2(j,3),'v2');
    %text(v3(j,1),v3(j,2),v3(j,3),'v3');
    %quiver3(v3(j,1),v3(j,2),v3(j,3), e1(j,1),e1(j,2),e1(j,3),0);
    %quiver3(v1(j,1),v1(j,2),v1(j,3), e2(j,1),e2(j,2),e2(j,3),0);
    %quiver3(v2(j,1),v2(j,2),v2(j,3), e3(j,1),e3(j,2),e3(j,3),0);
    %text((v3(j,1)+v2(j,1))/2,(v3(j,2)+v2(j,2))/2,(v3(j,3)+v2(j,3))/2,'e1');
    %text((v3(j,1)+v1(j,1))/2,(v3(j,2)+v1(j,2))/2,(v3(j,3)+v1(j,3))/2,'e2');
    %text((v1(j,1)+v2(j,1))/2,(v1(j,2)+v2(j,2))/2,(v1(j,3)+v2(j,3))/2,'e3');
    %quiver3(face_center(j,1),face_center(j,2),face_center(j,3), u(j,1),u(j,2),u(j,3),0);
    %quiver3(v3(j,1),v3(j,2),v3(j,3), Je1(1),Je1(2),Je1(3),0);
    %quiver3(v1(j,1),v1(j,2),v1(j,3), Je2(1),Je2(2),Je2(3),0);
    %quiver3(v2(j,1),v2(j,2),v2(j,3), Je3(1),Je3(2),Je3(3),0);
end
end