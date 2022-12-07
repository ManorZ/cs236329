function GV = create_GV(vertex, face)
vertex_area = calc_vertex_barycentric_cell_area(vertex, face);
n_vertex = size(vertex, 1);
i = 1:n_vertex;
GV = sparse(i,i,vertex_area);
end