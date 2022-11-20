function mat = create_edge_face_adj_mat(face)
%   create_edge_face_adj_mat - create non-symmetric vertex-face adjecency matrix from faces for a triangular
%   mesh
%   mat = create_edge_face_adj_mat(face)
%   'face' is a '#face x 3' array of faces, each entry contains 3 vertex
%   indices
%   'mat' is a sparse adjecency matrix of size '#edge x #face'
%   Copyright (c) 2022 Manor Zvi & Yissachar Abraham

n_vertex = max(face(:));
n_face = size(face, 1);

i = [
    (face(:,1) - 1) .* n_vertex + face(:,2);
    (face(:,2) - 1) .* n_vertex + face(:,3);
    (face(:,3) - 1) .* n_vertex + face(:,1);
    (face(:,1) - 1) .* n_vertex + face(:,3);
    (face(:,3) - 1) .* n_vertex + face(:,2);
    (face(:,2) - 1) .* n_vertex + face(:,1);
    ]; % edge indices - linear translation from 2-vertex index tuple (<int, int>) to 1-edge <int> index
j = [
    (1:n_face)';
    (1:n_face)';
    (1:n_face)'
    (1:n_face)';
    (1:n_face)';
    (1:n_face)'
    ]; % face indices

s = ones(size(i));
mat = sparse(i, j, s);
end