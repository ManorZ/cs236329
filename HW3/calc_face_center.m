function face_center = calc_face_center(vertex, face)
face_set = create_face_set(vertex, face);    
face_center = squeeze(mean(face_set, 2));
end