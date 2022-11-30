function Ifv = create_Ifv(vertex, face)
%   Ifv = create_Ifv(vertex, face)
%   Create Ifv interpolation matrix as defined at HW2, section 6
%   'vertex' is a '#vertex x 3' array specifying the position of the vertices.
%   'face' is a '#face x 3' array specifying the connectivity of the mesh.
%   'Ifv' is a '#face x #vertex' matrix that defined implicitly: Ifv =
%   inv(diag(face_area)) * Ivf' * diag(vertex_area)
%   Copyright (c) 2022 Manor Zvi & Yissachar Abraham
Av = diag(calc_vertex_area(vertex, face));
Af = diag(calc_face_area(vertex, face));
Ivf = create_Ivf(vertex, face);
Ifv = inv(Af) * Ivf' * Av;
end