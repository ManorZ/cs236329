function mat = create_vertex_face_adj_mat(face)
%   create_vertex_face_adj_mat - create non-symmetric vertex-face adjecency matrix from faces for a triangular
%   mesh
%   mat = create_vertex_face_adj_mat(face)
%   'face' is a '#face x 3' array of faces, each entry contains 3 vertex
%   indices
%   'mat' is a sparse adjecency matrix of size '#vertex x #face'
%   Copyright (c) 2022 Manor Zvi & Yissachar Abraham

n_face = size(face, 1);

i = [face(:, 1); face(:, 2); face(:, 3)]; % vertex indices
j = [(1:n_face)'; (1:n_face)'; (1:n_face)']; % face indices
s = ones(size(i));
mat = sparse(i, j, s);
end