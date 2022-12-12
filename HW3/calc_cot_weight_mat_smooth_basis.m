function [V, D] = calc_cot_weight_mat_smooth_basis(vertex, face, k, mode)
cot_weight_mat = calc_cot_weight_mat(vertex, face);
[V,D] = eigs(cot_weight_mat, k, mode);
end