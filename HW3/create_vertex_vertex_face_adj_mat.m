function mat = create_vertex_vertex_face_adj_mat(face)
%   create_vertex_vertex_face_adj_mat - create symmetric vertex-vertex adjacency matrix from faces for a triangular
%   mesh. each vertex-vertex adjacency cell contains the common face index.
%   mat = create_vertex_vertex_face_adj_mat(vertex, face)
%   'face' is a '#face x 3' array of faces, each entry contains 3 vertex
%   indices
%   'mat' is a sparse adjacency matrix of size '#vertex x #vertex'
%   Copyright (c) 2022 Manor Zvi & Yissachar Abraham

% i = [face(:, 1); face(:, 2); face(:, 3); face(:, 1); face(:, 2); face(:, 3)];
% j = [face(:, 2); face(:, 3); face(:, 1); face(:, 3); face(:, 1); face(:, 2)];
i = [face(:, 1); face(:, 2); face(:, 3)];
j = [face(:, 2); face(:, 3); face(:, 1)]; 
%s = ones(size(i));
n_face = size(face, 1);
s = [(1:n_face)';(1:n_face)';(1:n_face)'];
mat = sparse(i, j, s);
end