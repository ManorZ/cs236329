function vertex_area = calc_vertex_area(vertex, face)
%   calc_vertex_area(vertex, face)
%   Calculate each vertex area based on the sum of the neighboring faces
%   areas divided by 3.
%   'vertex' is a '#vertex x 3' array specifying the position of the vertices.
%   'face' is a '#face x 3' array specifying the connectivity of the mesh.
%   'vertex_area' is a '#vertex x 1' vector of vertex area
%   Copyright (c) 2022 Manor Zvi & Yissachar Abraham
face_area = calc_face_area(vertex, face);
vertex_face_adj_mat = create_vertex_face_adj_mat(face);
vertex_face_adj_mat = vertex_face_adj_mat / 3;
vertex_area = vertex_face_adj_mat * face_area;
end