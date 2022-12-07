function lap = calc_lap(vertex, face)
E = create_E(vertex, face);
GV = create_GV(vertex, face);
GF = create_GF(vertex, face);
lap = 0.25 * inv(GV) * E' * inv(GF) * E;
end