function [vertex, face] = read_mesh_off(filename)
%   read_mesh_off - read triangle 3D mesh from OFF file.
%   [vertex, face] = read_mesh_off(filename);
%   'vertex' is a '#vertex x 3' array specifying the position of the vertices.
%   'face' is a '#face x 3' array specifying the connectivity of the mesh.
%   Copyright (c) 2022 Manor Zvi & Yissachar Abraham

fid = fopen(filename,'r');

if( fid==-1 )
    error('Can''t open the file.');
    return;
end

type = fgets(fid);   % -1 if eof
type = type(1:3);
if ~strcmp(type, 'OFF')
    error('The file is not a valid OFF one.');    
end

size = fgets(fid);
[n_vertex, size] = strtok(size);
n_vertex = str2double(n_vertex);
[n_face, size] = strtok(size);
n_face = str2double(n_face);
n_edge = str2double(size);
if n_edge == 0
    n_edge = nan;
end

% read vertices section.
% assume 3D vertices (3 coords each)
[vertex, count] = fscanf(fid,'%f %f %f', 3 * n_vertex);
if count ~= 3 * n_vertex
    error('Problem in reading vertices.');
end
vertex = reshape(vertex, 3, count / 3)'; % I like them row-major

% read faces section.
% assume triangles only - 3 vertices per face
[face, count] = fscanf(fid,'%d %d %d %d\n', 4 * n_face);
if count ~= 4 * n_face
    error('Problem in reading faces.');
end
face = reshape(face, 4, count / 4)';
face_degree = face(:, 1);
face = face(:, 2:4) + 1; % vertex index starts at 0
if any(face_degree ~= 3)
    error('A non-triangle face detected');
end

fclose(fid);

end