function mat = calc_cot_weight_mat_smooth_basis_eigdecomp(vertex, face, k)
[V,D] = calc_cot_weight_mat_smooth_basis(vertex, face, k);
mat = V * D * V'; % V is col-orthonormal matrix, hence inv(V) === V'
end