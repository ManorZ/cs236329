function grad = calc_grad(vertex, face)
GF = create_GF(vertex, face);
E = create_E(vertex, face);
grad = 0.5 * inv(GF) * E;
end