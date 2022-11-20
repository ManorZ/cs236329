function genus = calc_genus(vertex, face)
    
    vv_adj_mat = create_vertex_vertex_adj_mat(face);
    
    n_vertex = size(vertex, 1);
    n_face = size(face, 1);
    
    [boundary_edge, ~] = calc_boundary_edge(vertex, face);
    n_boundary = length(boundary_edge) / 2
    n_edge = (sum(nonzeros(vv_adj_mat)) + n_boundary) / 2
    euler_characteristic = n_vertex + n_face - n_edge % chi = 2 - 2g - b -> 2g = 2 - b -chi
    n_boundary_components = ???
    genus = (2 - euler_characteristic - n_boundary_components) / 2;
end