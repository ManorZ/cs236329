from typing import List, Tuple
import numpy as np


def read_off_file(filename: str) -> Tuple[np.array, np.array, np.array]:
    with open(filename) as file:
        while True:
            line = file.readline()
            if line[0].isdigit():
                line.rstrip('\n')
                v, f, e = np.array(line.strip().split(' ')).astype(int)
                break

        vertices = np.array([np.array(file.readline().strip().split(' ')).astype(np.float32) for _ in range(v)])
        n_faces_colors = [file.readline().strip().split(' ') for _ in range(f)]
    n_faces_colors = np.array([list(filter(lambda val: val.isdigit(), values)) for values in n_faces_colors]).astype(int)
    faces = n_faces_colors[:, 0:4]
    color = n_faces_colors.T[5:8].T if n_faces_colors.shape[0] == 8 else None
    return vertices, faces, color


def connected_components(graph: List[Tuple[int, int]]) -> Tuple[int, List[List[Tuple[int,int]]]]:
    visited = np.array([False] * len(graph))
    components = []

    def _bfs(edge_list: List[List[int]], source_index: int):
        if visited[source_index]:
            return
        visited[source_index] = True
        components[-1].append(tuple(edge_list[source_index]))
        for i, edge in enumerate(edge_list):
            for s_val in edge_list[source_index]:
                if s_val in edge:
                    _bfs(edge_list, i)

    source = 0
    number_of_components = 0
    while not np.all(visited):
        components.append([])
        _bfs(graph, source)
        source = np.argmin(visited)
        number_of_components += 1

    return number_of_components, components
