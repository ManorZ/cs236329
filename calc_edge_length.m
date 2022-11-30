function edge_length = calc_edge_length(vertex, face)
face_set = create_face_set(vertex, face);
edge_length = [sqrt(sum(squeeze(face_set(:,1,:) - face_set(:,2,:)).^2, 2)), sqrt(sum(squeeze(face_set(:,2,:) - face_set(:,3,:)).^2, 2)), sqrt(sum(squeeze(face_set(:,3,:) - face_set(:,1,:)).^2, 2))];
end