function curvature = calc_gauss_curvature(vertex, face)
n_vertex = size(vertex, 1);

vertex_vertex_adj_mat = create_vertex_vertex_face_adj_mat(face);

vertex_area = calc_vertex_barycentric_cell_area(vertex, face);

curvature = zeros(n_vertex, 1);

for i = 1:n_vertex
    v_n1_idx = find(vertex_vertex_adj_mat(i,:));
    f_n1_idx = nonzeros(vertex_vertex_adj_mat(i,:));
    
    v = vertex(i,:);
    
    u = vertex(v_n1_idx,:);

    w = face(f_n1_idx,:)';
    w = w(find((w ~= v_n1_idx) & (w ~= ones(1,length(v_n1_idx))*i)));
    w = vertex(w,:);

    vu = u-v;
    vu = vu ./ sqrt(sum(vu.^2,2));
    vw = w-v;
    vw = vw ./ sqrt(sum(vw.^2,2));

    inner_prod = vu * vw';
    n1_cos = diag(inner_prod);
    n1_rad = acos(n1_cos);

    curvature(i) = (2*pi - sum(n1_rad)) / vertex_area(i);
    
end
end