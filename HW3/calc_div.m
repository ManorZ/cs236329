function div = calc_div(vertex, face)
grad = calc_grad(vertex, face);
GV = create_GV(vertex, face);
GF = create_GF(vertex, face);
div = -inv(GV) * grad' * GF;
end