function GF = create_GF(vertex, face)
[~, face_area] = calc_face_normal(vertex, face);
%GF = diag(face_area);
%GF = blkdiag(GF, GF, GF);
n_face = size(face, 1);
i = 1:3*n_face;
GF = sparse(i,i,[face_area',face_area',face_area']);
end