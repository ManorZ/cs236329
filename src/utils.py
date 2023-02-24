from typing import List, Tuple, Union
import numpy as np
import vtk
from scipy.special import lpmv


def read_off_file(filename: str) -> Tuple[np.array, np.array, np.array]:
    print('reading {}'.format(filename))
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


def legendre(deg,x):
    return np.asarray([lpmv(i,deg,x) for i in range(deg+1)])


def as_spherical(xyz: np.ndarray) -> np.ndarray:
    x, y, z = xyz.T
    r = np.linalg.norm(xyz, axis=1)
    theta = np.arccos(z / r) * 180 / np.pi  # to degrees
    phi = np.arctan2(y, x) * 180 / np.pi
    return np.array([r, theta, phi]).T


def vtk_point_locator(vtk_data: Union[vtk.vtkPolyData, vtk.vtkPoints]) -> vtk.vtkOctreePointLocator:
    p = vtk.vtkPolyData()
    if isinstance(vtk_data, vtk.vtkPoints):
        vtk_data = p.SetPoints(vtk_data)
    loc = vtk.vtkOctreePointLocator()
    loc.SetDataSet(vtk_data)
    loc.BuildLocator()
    return loc

def rigid_transform_3D(A, B):
    assert A.shape == B.shape
    A = A.T
    B = B.T
    num_rows, num_cols = A.shape
    if num_rows != 3:
        raise Exception(f"matrix A is not 3xN, it is {num_rows}x{num_cols}")

    num_rows, num_cols = B.shape
    if num_rows != 3:
        raise Exception(f"matrix B is not 3xN, it is {num_rows}x{num_cols}")

    # find mean column wise
    centroid_A = np.mean(A, axis=1)
    centroid_B = np.mean(B, axis=1)

    # ensure centroids are 3x1
    centroid_A = centroid_A.reshape(-1, 1)
    centroid_B = centroid_B.reshape(-1, 1)

    # subtract mean
    Am = A - centroid_A
    Bm = B - centroid_B

    H = Am @ np.transpose(Bm)

    # sanity check
    #if linalg.matrix_rank(H) < 3:
    #    raise ValueError("rank of H = {}, expecting 3".format(linalg.matrix_rank(H)))

    # find rotation
    U, S, Vt = np.linalg.svd(H)
    R = Vt.T @ U.T

    # special reflection case
    if np.linalg.det(R) < 0:
        print("det(R) < R, reflection detected!, correcting for it ...")
        Vt[2,:] *= -1
        R = Vt.T @ U.T

    t = -R @ centroid_A + centroid_B

    return R, t