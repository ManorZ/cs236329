function Ivf = create_Ivf(vertex, face)
%   Ivf = create_Ivf(vertex, face)
%   Create Ivf interpolation matrix as defined at HW2, section 6
%   'vertex' is a '#vertex x 3' array specifying the position of the vertices.
%   'face' is a '#face x 3' array specifying the connectivity of the mesh.
%   'Ivf' is a '#vertex x #face' matrix such that:
%       - Ivf(i,j) = face_area(j) / (vertex_area(i) * 3) iff face j belongs to the
%       one-ring of vertex i
%       - Ivf(i,j) = 0 otherwise
%   Copyright (c) 2022 Manor Zvi & Yissachar Abraham
Av = diag(calc_vertex_area(vertex, face));
adj_vf = create_vertex_face_adj_mat(face) / 3;
Af = diag(calc_face_area(vertex, face));
Ivf = inv(Av) * adj_vf * Af;
end