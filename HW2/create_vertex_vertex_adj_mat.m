function mat = create_vertex_vertex_adj_mat(face)
%   create_vertex_vertex_adj_mat - create symmetric vertex-vertex adjecency matrix from faces for a triangular
%   mesh
%   mat = create_vertex_vertex_adj_mat(face)
%   'face' is a '#face x 3' array of faces, each entry contains 3 vertex
%   indices
%   'mat' is a sparse adjecency matrix of size '#vertex x #vertex'
%   Copyright (c) 2022 Manor Zvi & Yissachar Abraham

% i = [face(:, 1); face(:, 2); face(:, 3); face(:, 1); face(:, 2); face(:, 3)];
% j = [face(:, 2); face(:, 3); face(:, 1); face(:, 3); face(:, 1); face(:, 2)];
i = [face(:, 1); face(:, 2); face(:, 3)];
j = [face(:, 2); face(:, 3); face(:, 1)]; 
s = ones(size(i));
mat = sparse(i, j, s);
end