from mesh import Mesh, CELL_AREA, VERTEX_AREA, EDGE_FACES
from utils import read_off_file
import glob, os
import numpy as np
import matplotlib.pyplot as plt
import time
import pyvista as pv
from scipy.linalg import null_space
from scipy import sparse
from matplotlib.ticker import ScalarFormatter

def check_triangulation_error(write):
    sphere_files = glob.glob(r'./hw2_data/sphere_*')
    errors = []
    number_of_faces = []
    sphere_names = []
    for off_file in sphere_files:
        vertices, faces, color = read_off_file(off_file)
        mesh = Mesh(faces=faces, vertices=vertices, color=color)
        errors.append(np.sum(1 - np.linalg.norm(mesh.face_centers, axis=1)) / mesh.n_faces)
        # sphere_names.append(os.path.basename(off_file).split('_')[1].split('.')[0])
        sphere_names.append(mesh.average_edge_lengths())
        number_of_faces.append(mesh.n_faces)

    fig, axs = plt.subplots(2)
    fig.suptitle('Mesh Triangulation Errors Comparison')

    axs[0].plot(sphere_names, errors, 'bo', sphere_names, errors, 'k')
    axs[0].set_title("Triangulation error")
    axs[0].set(xlabel='Sphere', ylabel="Triangulation Error")
    axs[0].label_outer()
    axs[0].grid()

    axs[1].plot(sphere_names, number_of_faces, 'bo', sphere_names, number_of_faces, 'k')
    axs[1].set_title("Mesh Sizes")
    axs[1].set(xlabel='Average edge length', ylabel="Number Of Triangles")
    axs[1].label_outer()
    axs[1].grid()

    xfmt = ScalarFormatter()
    xfmt.set_powerlimits((-3, 3))
    axs[1].yaxis.set_major_formatter(xfmt)
    # plt.grid()
    if write:
        plt.savefig("triangulation_error.png")
    plt.show()


def check_curvature_error(write, curvature_type ='Gaussian'):
    sphere_files = glob.glob(r'./hw2_data/sphere_*')
    errors = []
    number_of_faces = []
    sphere_names = []
    for off_file in sphere_files:
        print()
        vertices, faces, color = read_off_file(off_file)
        mesh = Mesh(faces=faces, vertices=vertices, color=color)
        errors.append(np.sum(mesh.poly_data.curvature(curvature_type) - 1)/ mesh.n_vertices)
        # sphere_names.append(os.path.basename(off_file).split('_')[1].split('.')[0])
        sphere_names.append(mesh.average_edge_lengths())
        number_of_faces.append(mesh.n_faces)

    fig, axs = plt.subplots(2)
    fig.suptitle('Mesh {} Curvature Errors Comparison'.format(curvature_type))

    axs[0].plot(sphere_names, errors, 'bo', sphere_names, errors, 'k')
    axs[0].set_title("Curvature error")
    axs[0].set(xlabel='Sphere', ylabel="Curvature Error")
    axs[0].label_outer()
    axs[0].grid()

    axs[1].plot(sphere_names, number_of_faces, 'bo', sphere_names, number_of_faces, 'k')
    axs[1].set_title("Mesh Sizes")
    axs[1].set(xlabel='Average edge length', ylabel="Number Of Triangles")
    axs[1].label_outer()
    axs[1].grid()
    xfmt = ScalarFormatter()
    xfmt.set_powerlimits((-3, 3))
    axs[1].yaxis.set_major_formatter(xfmt)

    if write:
        plt.savefig("{}_error.png".format(curvature_type))
    plt.show()


def check_vertex_rank_average(write=False):
    files = glob.glob(r'./hw2_data/*')
    mesh_names = []
    av_rank = []
    for off_file in files:
        vertices, faces, color = read_off_file(off_file)
        mesh = Mesh(faces=faces, vertices=vertices, color=color)
        av_rank.append(mesh.get_average_vertex_rank())
        mesh_names.append(os.path.basename(off_file).split('.')[0])

    fig, axs = plt.subplots(1)
    fig.suptitle('Average Vertex Ranks')
    axs.scatter(mesh_names, av_rank)
    axs.set(xlabel='Mesh', ylabel='Average Vertex Rank')
    axs.label_outer()
    plt.grid()
    fig.autofmt_xdate()
    if write:
        plt.savefig("vertex_rank_average.png")
    plt.show()


def face_vertex_interpolation(write=False):
    sphere_file = r'./hw2_data/sphere_s5.off'
    vertices, faces, color = read_off_file(sphere_file)
    mesh = Mesh(faces=faces, vertices=vertices, color=color)
    mesh.poly_data.curvature('Gaussian').mean()
    pp = pv.Plotter()
    pp.add_mesh(mesh.poly_data, scalars=mesh.face_areas)
    pp.open_movie("data_interpolation0.mp4") if write else False

    def run(v):
        face_data = mesh.face_areas
        # face_data = np.zeros(mesh.n_faces)
        # face_data[[0]] = 1
        for i in range(200):
            vertex_data = mesh.average_face_to_vertex(face_data)
            face_data = 0.5 * mesh.average_vertex_to_face(vertex_data)
            info = "iteration: {0:.0f}, face area: {1:.2f}, vertex area: {2:.2f}".format(i, np.sum(face_data), np.sum(vertex_data))
            print(info)
            pp.update_scalars(face_data, render=False)
            time.sleep(0.1)
            pp.update()
            pp.write_frame() if write else False
            pp.add_text(info, name='info')

    pp.add_checkbox_button_widget(run)
    pp.show()


def check_null_space_of_face_vertex_interpolator(mesh_off_file):
    vertices, faces, color = read_off_file(mesh_off_file)
    mesh = Mesh(faces=faces, vertices=vertices, color=color)

    ifv = mesh.face_vertex_adjacency
    null_v = null_space(ifv.todense())
    print("ifv null space", null_v.shape)
    ivf = sparse.eye(mesh.n_faces) * mesh.face_vertex_adjacency * sparse.eye(mesh.n_vertices)
    null_v = null_space(ifv.todense())
    print("ivf null space", null_v.shape)


def run_all_mesh_functions(mesh_off_file):
    vertices, faces, color = read_off_file(mesh_off_file)

    mesh = Mesh(faces=faces, vertices=vertices, color=color)

    mesh.vertex_normals
    mesh.face_normals

    mesh.gaussian_curvature()

    mesh.ivf
    mesh.ifv

    mesh.face_areas
    mesh.vertex_areas
    mesh.get_boundary_edges()
    mesh.get_boundary_faces()
    mesh.n_boundaries

    mesh.print(name=mesh_off_file)
    mesh.plot(CELL_AREA)
    mesh.plot(VERTEX_AREA)
    mesh.plot(EDGE_FACES)



if __name__ == '__main__':
    write = False
    mesh_off_file = r'./hw2_data/sphere_s0.off'
    run_all_mesh_functions(mesh_off_file=mesh_off_file)
    face_vertex_interpolation(write=write)
    check_triangulation_error(write=write)
    check_curvature_error(write, curvature_type="Gaussian")
    check_curvature_error(write, curvature_type="Mean")
