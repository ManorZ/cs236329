function error = sphere_triangulation_error(vertex, face)
    face_set = create_face_set(vertex, face);
    
    face_center = squeeze(mean(face_set, 2));
    X = face_center;
    S = X ./ sqrt(sum(X.^2, 2));
    D = X - S;
    D = sqrt(sum(D.^2, 2));
    n_face = size(face, 1);
    error = (1 / n_face) * sum(D);
    %plot_triangle_3d_mesh(vertex, face);
    %hold on;
    %plot3(face_center(:, 1), face_center(:, 2), face_center(:, 3), '-o','Color','b','MarkerSize',4, 'MarkerFaceColor','#D9FFFF')
end