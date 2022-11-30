function genus = calc_genus(vertex, face)
    
    vv_adj_mat = create_vertex_vertex_adj_mat(face);
    
    n_vertex = size(vertex, 1)
    n_face = size(face, 1)
    
    [boundary_edge, boundary_face] = calc_boundary_edge(vertex, face); % each edge is counted twice - need to fix it later
    n_boundary = length(boundary_edge) / 2;
    n_edge = (sum(nonzeros(vv_adj_mat)) + n_boundary) / 2
    euler_characteristic = n_vertex + n_face - n_edge % chi = 2 - 2g - b -> 2g = 2 - b -chi
    
    n_boundary_components = 0;
    if length(boundary_edge) > 0
        boundary_vertex = sort(unique(boundary_edge));
        boundary_vv_adj_mat = sparse(max(boundary_vertex(:)), max(boundary_vertex(:)));
        for i = 1 : size(boundary_edge, 1)
            curr_edge = boundary_edge(i, :);
            boundary_vv_adj_mat(curr_edge(1), curr_edge(2)) = 1;
        end
        boundary_graph = graph(boundary_vv_adj_mat);
    
        
        while ~isempty(boundary_vertex)
            dfs = sort(dfsearch(boundary_graph, boundary_vertex(1)));
            boundary_vertex = boundary_vertex(boundary_vertex~=dfs);
            n_boundary_components = n_boundary_components + 1;
        end
    end
    genus = (2 - euler_characteristic - n_boundary_components) / 2
end