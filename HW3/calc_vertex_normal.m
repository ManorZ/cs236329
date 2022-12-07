function vertex_normal = calc_vertex_normal(vertex, face)
[face_normal, face_area] = calc_face_normal(vertex, face);
vertex_face_adj_mat = create_vertex_vertex_face_adj_mat(face);

n_vertex = size(vertex, 1);
vertex_normal = zeros(n_vertex, 3);
for i = 1:n_vertex
    vertex_normal(i,:) = face_area(nonzeros(vertex_face_adj_mat(i,:)))' * face_normal(nonzeros(vertex_face_adj_mat(i,:)),:);
end
end