function vertex_valence = calc_valence(vertex, face)
vv_aj_mat = create_vertex_vertex_adj_mat(face);
vertex_valence = full(sum(vv_aj_mat, 2));
end