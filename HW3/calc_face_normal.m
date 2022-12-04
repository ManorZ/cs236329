function [face_normal, face_area] = calc_face_normal(vertex, face)
face_set = create_face_set(vertex, face);
v1 = squeeze(face_set(:,2,:) - face_set(:,1,:));
v2 = squeeze(face_set(:,3,:) - face_set(:,1,:)); 
v3 = squeeze(face_set(:,3,:) - face_set(:,2,:));
face_normal = cross(v1, v2);
% sanity check
eps = 1e-8;
if (sum(abs(dot(face_normal, v1, 2))) > eps) || (sum(abs(dot(face_normal, v2, 2))) > eps) || (sum(abs(dot(face_normal, v3, 2))) > eps)
    warning('Normal are not perpendicular to faces (errors: %d, %d, %d)', sum(abs(dot(face_normal, v1, 2))), sum(abs(dot(face_normal, v2, 2))), sum(abs(dot(face_normal, v3, 2))));
end
face_area = 0.5 * sqrt(sum(face_normal.^2,2));
end