function plot_triangle_3d_mesh(vertex, face, options)
%   plot_triangle_3d_mesh(vertex, face, options)
%   Plot triangle 3D mesh (all faces are triangles, all vertices are in 3D space)
%   'vertex' is a '#vertex x 3' array specifying the position of the vertices.
%   'face' is a '#face x 3' array specifying the connectivity of the mesh.
%   'options' is a structure that may contains:
%       - 'vertex_color' : a color per vertex ('#vertex x 1' or '#vertex x 3')
%       - 'face_color' : a color per face
%   Copyright (c) 2022 Manor Zvi & Yissachar Abraham

vertex_color = getoptions(options, 'vertex_color', []);
face_color   = getoptions(options, 'face_color', []);

view(3);

if isempty(vertex_color) && isempty(face_color)
    patch('vertices',vertex,'faces',face, 'FaceColor', 'white');
end

if ~isempty(vertex_color) && isempty(face_color)
    if size(vertex_color, 1) ~= size(vertex, 1)
        error('vertex_color mismatch vs. vertex');
    end
    if (size(vertex_color, 2) ~= 1) && (size(vertex_color, 2) ~= 3)
        error('vertex_color illegal size');
    end
    patch('vertices',vertex,'faces',face, 'FaceVertexCData', vertex_color, 'FaceColor', 'interp');
    axis square;
    grid on;
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
end
if isempty(vertex_color) && ~isempty(face_color)
    if size(face_color, 1) ~= size(face, 1)
        error('face_color size (%dx%d) mismatch vs. face (%dx%d)', size(face_color, 1), size(face_color, 2), size(face, 1), size(face, 2));
    end
    if (size(face_color, 2) ~= 1) && (size(face_color, 2) ~= 3)
        error('face_color illegal size');
    end
    patch('vertices',vertex,'faces',face, 'FaceVertexCData', face_color, 'FaceColor', 'flat');
    axis square;
    grid on;
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
end
if ~isempty(vertex_color) && ~isempty(face_color)
    warning('Both face_color and vertex_color together is currently unsupported.')
end