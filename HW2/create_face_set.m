function face_set = create_face_set(vertex, face)
%   create_face_set(vertex, face)
%   Create a Face Set data structure from vertices & faces arrays of 3D
%   triangle mesh
%   'vertex' is a '#vertex x 3' array specifying the position of the vertices.
%   'face' is a '#face x 3' array specifying the connectivity of the mesh.
%   'face_set' is a '#face x 3 x 3' where: for each face, 3 adj vertices with 3D coords.
%   Copyright (c) 2022 Manor Zvi & Yissachar Abraham
face_set = reshape(vertex(face, :), [size(face, 1), 3, 3]);
end