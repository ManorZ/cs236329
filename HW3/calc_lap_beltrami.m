function lap = calc_lap_beltrami(vertex, face, vertex_func)

n_face = size(face, 1);
n_vertex = size(vertex, 1);
n_edge = n_vertex * n_vertex;

face_cot = create_face_cot(vertex, face);

vertex_vertex_cot_adj_mat = sparse( ...
    [face(:, 1);    face(:, 2);     face(:, 3)], ...
    [face(:, 2);    face(:, 3);     face(:, 1)], ...
    [face_cot(:,3); face_cot(:,1);  face_cot(:,2)] ...
);

vertex_area = calc_vertex_barycentric_cell_area(vertex, face);

lap = zeros(n_vertex, size(vertex_func, 2));

for i = 1:n_vertex
    v_n1_idx = find(vertex_vertex_cot_adj_mat(i,:));
    v_func = vertex_func(i);
    v_n1_func = vertex_func(v_n1_idx,:);

    v_n1_cot_left = nonzeros(vertex_vertex_cot_adj_mat(i,:));
    v_n1_cot_right = nonzeros(vertex_vertex_cot_adj_mat(:,i));

    v_n1_cot_weight = v_n1_cot_left + v_n1_cot_right;
    %v_n1_func_change = v_n1_func - v_func;
    v_n1_func_change = v_func - v_n1_func;

    lap(i,:) = (v_n1_cot_weight' * v_n1_func_change) / (2*vertex_area(i));
end
end