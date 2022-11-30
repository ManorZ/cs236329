function [boundary_edge, boundary_face] = calc_boundary_edge(vertex, face)
%   calc_boundary_edge - calculate the set of boundary edges in a 3D
%   triangle mesh
%   boundary = calc_boundary_edge(vertex, face)
%   'vertex' is a '#vertex x 3' array specifying the position of the vertices.
%   'face' is a '#face x 3' array specifying the connectivity of the mesh.
%   'boundary_edge' is an array contains edges on the boundary of the mesh
%   'boundary_face' is an array contains faces on the edge - one face for
%   each edge of 'boundary_edge'
%   note(1): empty arrays means closed mesh (without boundaries)
%   note(2): edge index between two vertex indices is given as follows:
%   (<v1 index>-1) * |V| + <v2 index>
%   Copyright (c) 2022 Manor Zvi & Yissachar Abraham
boundary_edge = [];
boundary_face = [];
ef_adj_mat = create_edge_face_adj_mat(face);
boundary_edge = find(sum(ef_adj_mat, 2)==1);
[~, boundary_face] = find(ef_adj_mat(boundary_edge,:));

n_vertex = max(face(:));
boundary_v2 = mod(boundary_edge, n_vertex);
boundary_v1 = (boundary_edge - boundary_v2) / n_vertex + 1;
boundary_edge = [boundary_v1, boundary_v2];

end