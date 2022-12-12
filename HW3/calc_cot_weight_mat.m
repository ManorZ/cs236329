function mat = calc_cot_weight_mat(vertex, face)
E = create_E(vertex, face);
Gf = create_GF(vertex, face);
mat = 0.25 * E' * inv(Gf) * E;
end