from typing import Callable
from mesh import Mesh
import numpy as np
import glob
from utils import read_off_file

from scipy import sparse as sp


def plot_gradient(mesh: Mesh):
    f = np.zeros(mesh.n_vertices)
    f[:20] = 1
    f = mesh.vertex_areas
    v = mesh.calculate_grad(f)
    mesh.poly_data.point_data['function values'] = f
    mesh.plot_vectors(v, 'grad')


def plot_div(mesh: Mesh):
    f = np.ones(mesh.n_vertices)
    f[:20] = 2
    v = mesh.calculate_grad(f)
    # v = mesh.face_normals.reshape(-1, 1)
    f = mesh.div() * v.reshape(-1, 1)
    mesh.plot_function(f, 'div')


def plot_laplace(mesh: Mesh):
    f = np.ones(mesh.n_vertices)
    f[:20] = 2
    f = mesh.L() * f
    mesh.plot_function(f)


def plot_gaussian_curvature(mesh: Mesh):
    f = mesh.gaussian_curvature()
    mesh.plot_function(f, 'gaussian curvature')


def plot_mean_curvature(mesh: Mesh):
    f = mesh.mean_curveture()
    mesh.plot_function(f, 'mean curvature')


def compute_null(mesh: Mesh):
    f = np.ones(mesh.n_vertices)
    print('NULL of cotangent weights norm W*f = ', np.linalg.norm(mesh.cot_weights() * f))


def compute_sym(mesh: Mesh):
    print('SYM of cotangent weights norm |W - WT| = ', sp.linalg.norm(mesh.cot_weights() - mesh.cot_weights().T))


def compute_loc(mesh: Mesh):
    m = mesh.cot_weights()
    print('LOC of cotangent weights n_nozero = {} , n_edges = {}'.format(m.nnz, mesh.n_edges))
    print('-> ratio n_weights/n_edges = {}'.format(m.nnz / mesh.n_edges))


def compute_pos(mesh: Mesh):
    w = mesh.cot_weights()
    print('POS the minimum weight {}, the maximum weight {}'.format(w.min(), w.max()))


def compute_psd(mesh: Mesh):
    pass


def run_check(function: Callable, mesh: Mesh):
    function(mesh)

#
# def reduced_basis(mesh: Mesh):
#     h = mesh.cot_weights()
#     w, v = sp.linalg.eigs(h, 6, which='SM')
#     B = np.real(np.vstack(v))
#     M = ht @ np.diag(np.real(w)) @ ht.T
#
#     return


def print_cotangent_weights_matrix_props():
    functions = [ compute_null, compute_sym, compute_loc, compute_pos, compute_psd]
    sphere_files = glob.glob(r'./hw2_data/sphere_*')

    for off_file in sphere_files:
        vertices, faces, color = read_off_file(off_file)
        mesh = Mesh(faces=faces, vertices=vertices, color=color)
        for func in functions:
            run_check(func, mesh)


def plot_operators():
    functions = [plot_gaussian_curvature, plot_mean_curvature, plot_gradient, plot_div, plot_laplace]
    sphere_files = glob.glob(r'./hw2_data/*')

    for off_file in sphere_files:
        vertices, faces, color = read_off_file(off_file)
        mesh = Mesh(faces=faces, vertices=vertices, color=color)
        # reduced_basis(mesh)
        for func in functions:
            run_check(func, mesh)


if __name__ == '__main__':
    # print_cotangent_weights_matrix_props()
    plot_operators()
