function face_cot = create_face_cot(vertex, face)
face_edge_set = create_face_edge_set(vertex, face);
face_cot = [
    dot(face_edge_set(:,:,1),-face_edge_set(:,:,3), 2) ./ sqrt(sum(cross(face_edge_set(:,:,1),-face_edge_set(:,:,3)).^2,2)), ...
    dot(face_edge_set(:,:,2),-face_edge_set(:,:,1), 2) ./ sqrt(sum(cross(face_edge_set(:,:,2),-face_edge_set(:,:,1)).^2,2)), ...
    dot(face_edge_set(:,:,3),-face_edge_set(:,:,2), 2) ./ sqrt(sum(cross(face_edge_set(:,:,3),-face_edge_set(:,:,2)).^2,2))
];
end