function face_area = calc_face_area(vertex, face)
%   calc_face_area(vertex, face)
%   Calculate each face area based on a cross product
%   'vertex' is a '#vertex x 3' array specifying the position of the vertices.
%   'face' is a '#face x 3' array specifying the connectivity of the mesh.
%   'face_area' is a '#face x 1' vector of faces area
%   Copyright (c) 2022 Manor Zvi & Yissachar Abraham
face_set = create_face_set(vertex, face);
v1 = face_set(:,:,2) - face_set(:,:,1);
v2 = face_set(:,:,3) - face_set(:,:,1); 
normal = cross(v1, v2);
% sanity check
eps = 1e-8;
if (sum(abs(dot(normal, v1, 2))) > eps) || (sum(abs(dot(normal, v2, 2))) > eps)
    warning('Normal are not perpendicular to faces (errors: %d, %d)', sum(abs(dot(normal, v1, 2))), sum(abs(dot(normal, v2, 2))))
end
face_area = 0.5 * sqrt(sum(normal.^2,2));
end