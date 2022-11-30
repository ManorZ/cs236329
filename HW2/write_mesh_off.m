function write_mesh_off(filename, vertex, face)
%   write_mesh_off - write triangle 3D mesh to OFF file.
%   write_mesh_off(vertex, face);
%   'vertex' is a '#vertex x 3' array specifying the position of the vertices.
%   'face' is a '#face x 3' array specifying the connectivity of the mesh.
%   Copyright (c) 2022 Manor Zvi & Yissachar Abraham

if size(vertex, 2) ~= 3
    vertex = vertex';
end

if size(vertex, 2) ~= 3
    error('vertex does not have the correct format.');
end

if size(face, 2) ~= 3
    face = face';
end
if size(face, 2) ~= 3
    error('face does not have the correct format.');
end

fid = fopen(filename, 'wt');
if fid == -1
    error('Can''t open the file.');
    return;
end

fprintf(fid, 'OFF\n');
fprintf(fid, '%d %d 0\n', size(vertex, 1), size(face, 1));
fprintf(fid, '%f %f %f\n', vertex');
fprintf(fid, '3 %d %d %d\n', face' - 1);

end