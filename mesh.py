from typing import List, Tuple
import numpy as np
import pyvista as pv
from scipy.sparse import bsr_matrix, csc_matrix
from scipy import sparse

from utils import connected_components, read_off_file

VERTEX_AREA = 'VERTEX_AREA'
CELL_AREA = 'CELL_AREA'
COLOR = 'COLOR'
EDGE_FACES = 'EDGE_FACES'
EDGE_VERTICES = 'EDGE_VERTICES'


def dot(a, b):
    return np.sum(a * b, axis=1)


def angle(a, b):
    return np.arccos(dot(a, b) / (np.linalg.norm(a, axis=1) * np.linalg.norm(b, axis=1)))


def cot(a, b):
    return dot(a, b) / np.linalg.norm(np.cross(a, b, axis=1), axis=1)


class Mesh:
    vertex_adjacency_matrix: bsr_matrix
    face_vertex_adjacency: bsr_matrix
    edge_vertex_adjacency: bsr_matrix
    boundary_edges: List[Tuple[int, int]]

    def __init__(self, vertices, faces, color=None):
        self._n_edges = None
        self._edges = None
        self._n_boundaries = None
        self._vertex_adjacency_matrix = None
        self._face_vertex_adjacency = None
        self._edge_vertex_adjacency = None
        self._edge_face_adjacency = None
        self._face_centers = None
        self._face_areas = None
        self._vertex_areas = None
        self._ivf = None
        self._ifv = None
        self._face_normals = None
        self._vertex_normals = None
        self._je = None

        self.vertices = vertices
        self.faces = faces
        self.color = color
        if color is not None:
            self.poly_data.cell_data[COLOR] = color
        self.poly_data = pv.PolyData(self.vertices, self.faces)

    @property
    def face_normals(self):
        if self._face_normals is None:
            n, f = self.faces.T[0].T, self.faces.T[1:4]

            # get vertices of each triangle
            v0 = self.vertices[f[0]]
            v1 = self.vertices[f[1]]
            v2 = self.vertices[f[2]]
            face_normals = np.cross(v0 - v1, v1 - v2, axis=1)
            self._face_normals = face_normals / np.linalg.norm(face_normals, axis=1)[:, np.newaxis]
        return self._face_normals

    @property
    def vertex_normals(self):
        if self._vertex_normals is None:
            n, f = self.faces.T[0].T, self.faces.T[1:4]

            # get vertices of each triangle
            v0 = self.vertices[f[0]]
            v1 = self.vertices[f[1]]
            v2 = self.vertices[f[2]]
            face_normals = 0.5 * np.cross(v0 - v1, v1 - v2, axis=1)
            vertex_normals = self.face_vertex_adjacency.T * face_normals
            self._vertex_normals = vertex_normals  # / np.linalg.norm(vertex_normals, axis=1)[:, np.newaxis]
        return self._vertex_normals

    def E(self):
        n, f = self.faces.T[0].T, self.faces.T[1:4]
        v0 = self.vertices[f[0]]
        v1 = self.vertices[f[1]]
        v2 = self.vertices[f[2]]

        e0 = np.hstack(np.cross(v0 - v1, self.face_normals, axis=1).T)
        e1 = np.hstack(np.cross(v1 - v2, self.face_normals, axis=1).T)
        e2 = np.hstack(np.cross(v2 - v0, self.face_normals, axis=1).T)

        fn = np.hstack([f[2]] * 3 + [f[0]] * 3 + [f[1]] * 3)
        fxyz = np.array(np.hstack([np.array(range(3 * self.n_faces))] * 3))
        m = bsr_matrix((np.hstack([e0, e1, e2]), np.vstack([fxyz, fn])))
        return m

    def Gf(self, inverse=False):
        gf = sparse.eye(3 * self.n_faces)
        d = 1 / self.face_areas if inverse else self.face_areas
        gf.setdiag(np.hstack([d] * 3))
        return gf

    def Gv(self, inverse=False):
        gv = sparse.eye(self.n_vertices)
        d = 1 / self.vertex_areas if inverse else self.vertex_areas
        gv.setdiag(self.vertex_areas)
        return gv

    def grad(self):
        return 0.5 * self.Gf(inverse=True) * self.E()

    def calculate_grad(self, fv):
        vg = self.grad() * fv
        return vg.reshape((3, self.n_faces)).T

    def div(self):
        return -self.Gv(inverse=True) * self.grad().T * self.Gf()

    def cot_weights(self):
        return self.E().T * self.Gf(inverse=True) * self.E()

    def L(self):
        return 0.25 * self.Gv(inverse=True) * self.cot_weights()

    def get_points_from_edges(self, index=0):
        ze1, ze2 = self.vertex_edge_adjacency.nonzero()
        zet = np.hstack([ze1[ze2 == index], ze2[ze2 == index]])
        points = self.vertices[np.hstack(self.edges.T[zet].T)]
        return points

    def get_points(self, index=0):
        ze1, ze2 = self.vertex_adjacency_matrix.nonzero()
        zet = ze2[ze1 == index]
        return self.vertices[zet]

    @property
    def edges(self):
        if self._edges is None:
            n, f = self.faces.T[0].T, self.faces.T[1:4]
            e1 = np.ravel_multi_index(np.sort(np.vstack([f[0], f[1]]), axis=0), dims=(self.n_vertices, self.n_vertices), order='F')
            e2 = np.ravel_multi_index(np.sort(np.vstack([f[1], f[2]]), axis=0), dims=(self.n_vertices, self.n_vertices), order='F')
            e3 = np.ravel_multi_index(np.sort(np.vstack([f[2], f[0]]), axis=0), dims=(self.n_vertices, self.n_vertices), order='F')
            e = np.vstack([e1, e2, e3]).ravel(order='F')
            u = np.unique(e)
            self._edges = np.array(np.unravel_index(u, (self.n_vertices, self.n_vertices), order='F'))
        return self._edges

    @property
    def n_vertices(self):
        return len(self.vertices)

    @property
    def n_faces(self):
        return len(self.faces)

    @property
    def n_edges(self):
        self._n_edges = self.edges.size / 2 if self._n_edges is None else self._n_edges
        return int(self._n_edges)

    @property
    def chi(self):
        return self.n_vertices - self.n_edges + self.n_faces  # Euler

    @property
    def n_boundaries(self):
        if self.boundary_edges.size == 0:
            return 0
        if self._n_boundaries is None:
            self._n_boundaries, _ = connected_components(self.boundary_edges)
        return self._n_boundaries

    @property
    def n_boundary_edges(self):
        return self.boundary_edges.__len__()

    @property
    def n_genus(self):
        return int((2 - self.chi - self.n_boundaries) / 2)  # χ = 2 − 2g − b

    @property
    def vertex_adjacency_matrix(self):
        if self._vertex_adjacency_matrix is None:
            n, f = self.faces.T[0].T, self.faces.T[1:4]
            f1 = np.vstack([f[2], f[0], f[1]]).ravel()
            self._vertex_adjacency_matrix = bsr_matrix((np.ones(f1.size), np.vstack([f.ravel(), f1])), shape=(self.n_vertices, self.n_vertices))
        return self._vertex_adjacency_matrix

    @property
    def face_vertex_adjacency(self):
        if self._face_vertex_adjacency is None:
            _, f = self.faces[:, 0], self.faces[:, 1:4]
            f_idxs = np.vstack([range(self.n_faces)] * 3).T
            self._face_vertex_adjacency = bsr_matrix((np.ones(f_idxs.size), np.vstack([f_idxs.ravel(), f.ravel()])), shape=(self.n_faces, self.n_vertices))
        return self._face_vertex_adjacency

    @property
    def ivf(self):
        if self._ivf is None:
            self._ivf = 1 / 3 * self.face_vertex_adjacency.T
        return self._ivf

    @property
    def ifv(self):
        if self._ifv is None:
            Av = sparse.eye(self.n_vertices)
            Av.setdiag(1 / self.vertex_areas)
            Af = sparse.eye(self.n_faces)
            Af.setdiag(self.face_areas)
            self._ifv = Av * self.face_vertex_adjacency.T * Af
        return self._ifv

    # @property
    # def vertex_edge_adjacency(self):
    #     if self._edge_vertex_adjacency is None:
    #         edges = np.array(self.vertex_adjacency_matrix.nonzero()).T[:self.n_edges]  # take only top half of matrix
    #         e_idxs = np.vstack([range(self.n_edges)] * 2).T
    #         self._edge_vertex_adjacency = bsr_matrix((np.ones(e_idxs.size), np.vstack([edges.ravel(), e_idxs.ravel()])), shape=(self.n_vertices, self.n_edges))
    #     return self._edge_vertex_adjacency

    @property
    def vertex_edge_adjacency(self):
        if self._edge_vertex_adjacency is None:
            edges = np.array(self.vertex_adjacency_matrix.nonzero()).T  # take only top half of matrix
            e_idxs = np.vstack([range(2 * self.n_edges)] * 2).T
            self._edge_vertex_adjacency = bsr_matrix((np.ones(e_idxs.size), np.vstack([edges.ravel(), e_idxs.ravel()])), shape=(self.n_vertices, 2 * self.n_edges))
        return self._edge_vertex_adjacency

    @property
    def edge_face_adjacency(self):
        if self._edge_face_adjacency is None:
            n, f = self.faces.T[0].T, self.faces.T[1:4]
            e1 = np.ravel_multi_index(np.sort(np.vstack([f[0], f[1]]), axis=0), dims=(self.n_vertices, self.n_vertices), order='F')
            e2 = np.ravel_multi_index(np.sort(np.vstack([f[1], f[2]]), axis=0), dims=(self.n_vertices, self.n_vertices), order='F')
            e3 = np.ravel_multi_index(np.sort(np.vstack([f[2], f[0]]), axis=0), dims=(self.n_vertices, self.n_vertices), order='F')
            e = np.vstack([e1, e2, e3]).ravel(order='F')
            u = np.unique(e)
            dmap = dict(zip(u, range(u.size)))
            e = np.array([dmap[v] for v in e])
            f = np.vstack([range(self.n_faces)] * 3).ravel(order='F')
            self._edge_face_adjacency = bsr_matrix((np.ones(e.size), np.vstack([e, f])))
        return self._edge_face_adjacency

    @property
    def face_centers(self):
        if self._face_centers is None:
            n, f = self.faces.T[0].T, self.faces.T[1:4]
            self._face_centers = np.mean(self.vertices[f.T], axis=1)
        return self._face_centers

    @property
    def face_areas(self):
        if self._face_areas is None:
            n, idx1, idx2, idx3 = self.faces.T
            v1 = self.vertices[idx1] - self.vertices[idx2]
            v2 = self.vertices[idx1] - self.vertices[idx3]
            self._face_areas = 0.5 * np.linalg.norm(np.cross(v1, v2), axis=1)
            self.poly_data.cell_data[CELL_AREA] = self.face_areas
        return self._face_areas

    @property
    def vertex_areas(self):
        if self._vertex_areas is None:
            self._vertex_areas = self.ivf * self.face_areas
            self.poly_data.point_data[VERTEX_AREA] = self._vertex_areas
        return self._vertex_areas

    def average_edge_lengths(self):
        v1, v2 = self.edges
        return np.sum(np.linalg.norm(self.vertices[v1] - self.vertices[v2], axis=1)) / self.n_edges

    def plot_p(self, points):
        pp = pv.Plotter()
        pp.add_mesh(self.poly_data, opacity=0.5, show_edges=1)
        pp.add_points(points, color='r')
        pp.show()

    def collect_cot_weights(self):
        n, f = self.faces.T[0].T, self.faces.T[1:4]

        # get vertices of each triangle
        v0 = self.vertices[f[0]]
        v1 = self.vertices[f[1]]
        v2 = self.vertices[f[2]]

        def _w(a, b, c):
            _v1 = self.vertices[a]
            _v2 = self.vertices[b]
            _v3 = self.vertices[c]
            c = cot(_v1 - _v2, _v1 - _v3)
            d = np.linalg.norm(_v2 - _v3, axis=1)
            c = c * d
            co = np.vstack([b, c]).astype(int)
            idxs = np.sum(co * np.ones_like(co), axis=0)
            return bsr_matrix((c, np.vstack([idxs, range(self.n_faces)])))

        # cot_matrix = _w(f[0], f[1], f[2]) + _w(f[1], f[2], f[0]) + _w(f[2], f[0], f[1])

        # calculate the cotangence of each edge in triangle
        c1 = cot(v0 - v1, v0 - v2)  # edge 1 - 2
        c2 = cot(v1 - v2, v1 - v0)  # edge 2 - 0
        c3 = cot(v2 - v0, v2 - v1)  # edge 0 - 1
        c4 = cot(v0 - v2, v0 - v1)  # edge 1 - 2
        c5 = cot(v1 - v0, v1 - v2)  # edge 2 - 0
        c6 = cot(v2 - v1, v2 - v0)  # edge 0 - 1

        d1 = v1 - v2
        d2 = v2 - v0
        d3 = v0 - v1
        d4 = v2 - v1
        d5 = v0 - v2
        d6 = v1 - v0
        # d1 = np.linalg.norm(v1 - v2, axis=1)
        # d2 = np.linalg.norm(v2 - v0, axis=1)
        # d3 = np.linalg.norm(v0 - v1, axis=1)

        # c = np.vstack([c1 * d1, c2 * d2, c3 * d3]).ravel(order='F')
        # c = np.vstack([c1 , c2 , c3 ]).ravel(order='F')
        d = np.vstack([d1, d2, d3, d4, d5, d6])

        c = np.vstack([c1, c2, c3, c4, c5, c6]).ravel(order='F')
        # find the corresponding edges
        # e1 = np.ravel_multi_index(np.sort(np.vstack([f[1], f[2]]), axis=0), dims=(self.n_vertices, self.n_vertices), order='F')
        # e2 = np.ravel_multi_index(np.sort(np.vstack([f[2], f[0]]), axis=0), dims=(self.n_vertices, self.n_vertices), order='F')
        # e3 = np.ravel_multi_index(np.sort(np.vstack([f[0], f[1]]), axis=0), dims=(self.n_vertices, self.n_vertices), order='F')
        e1 = np.ravel_multi_index(np.vstack([f[1], f[2]]), dims=(self.n_vertices, self.n_vertices), order='F')
        e2 = np.ravel_multi_index(np.vstack([f[2], f[0]]), dims=(self.n_vertices, self.n_vertices), order='F')
        e3 = np.ravel_multi_index(np.vstack([f[0], f[1]]), dims=(self.n_vertices, self.n_vertices), order='F')
        e4 = np.ravel_multi_index(np.vstack([f[2], f[1]]), dims=(self.n_vertices, self.n_vertices), order='F')
        e5 = np.ravel_multi_index(np.vstack([f[0], f[2]]), dims=(self.n_vertices, self.n_vertices), order='F')
        e6 = np.ravel_multi_index(np.vstack([f[1], f[0]]), dims=(self.n_vertices, self.n_vertices), order='F')
        #
        # e = np.vstack([e1, e2, e3]).ravel(order='F')
        e = np.vstack([e1, e2, e3, e4, e5, e6]).ravel(order='F')
        u = np.unique(e)
        dmap = dict(zip(u, range(u.size)))
        e = np.array([dmap[v] for v in e])

        # create matrix edges cotangent values size of n_edgesX2*n_edges (two angles for each edge)
        # ff = np.array(range(2* self.n_edges))
        ff = np.hstack([range(c.size)])
        cot_matrix = bsr_matrix((c, np.vstack([ff, e])))
        test = bsr_matrix((np.ones_like(c), np.vstack([ff, e])))  # set ones

        # sum alpha and beta of each edge
        cot_values = cot_matrix.T * d
        # cot_values_f =  cot_values[:, np.newaxis] * d
        cot_values_test = test.T * np.ones(4 * self.n_edges)

        vertex_cot_values = self.vertex_edge_adjacency * cot_values
        vertex_cot_values_test = self.vertex_edge_adjacency * sparse.diags(cot_values_test)

        sum_vertex_cot_values = vertex_cot_values * np.linalg.norm(d, axis=1) / 2
        s = sparse.eye(self.n_vertices)
        s.setdiag(1 / self.vertex_areas)

        cot_values = cot_matrix.T * vajd  # shape = n_edges (value = cot(alpha) + cot(beta))

        cot_values = 0.5 * cot_values.sum(0) * s
        cot_values_test = test * self.vertex_edge_adjacency.T  # values 2
        m = self.vertex_edge_adjacency * cot_values  # the sum of cot values for each vertex
        mt = self.vertex_edge_adjacency * cot_values_test  # av(values) = 12 = 2 * av(vertex rank)
        # sum cotangent for each vertex
        # nbrs = self.vertex_adjacency_matrix.nonzero()
        # nbrs = np.ravel_multi_index(np.sort(nbrs, axis=0), dims=(self.n_vertices, self.n_vertices), order='F')
        # nbrs = np.array([dmap[v] for v in nbrs])
        # n = cot_values[nbrs]
        # cot_matrix = bsr_matrix((n, self.vertex_adjacency_matrix.nonzero()))
        # compute laplacian 1/2A * sum(cot)
        v = m / np.sum(self.vertex_areas)
        # v = 1/(2*self.vertex_areas) * m
        # v =  cot_matrix * np.ones(self.n_vertices)
        # v =  self.poly_data.curvature()
        self.poly_data.point_data['c'] = v
        self.poly_data.set_active_scalars('c')
        self.poly_data.plot(show_edges=True)
        s = 2

    def mean_curveture(self):
        return np.linalg.norm(self.L() * self.vertices, axis=1)

    def gaussian_curvature(self):
        n, f = self.faces.T[0].T, self.faces.T[1:4]

        # get vertices of each triangle
        v0 = self.vertices[f[0]]
        v1 = self.vertices[f[1]]
        v2 = self.vertices[f[2]]

        # calculate the angle of each edge in triangle
        c1 = angle(v0 - v1, v0 - v2)  # edge 1
        c2 = angle(v1 - v2, v1 - v0)  # edge 2
        c3 = angle(v2 - v0, v2 - v1)
        vidx = np.hstack(f)
        fidx = np.hstack([range(self.n_faces)] * 3)
        m = bsr_matrix((np.hstack([c1, c2, c3]), np.vstack([vidx, fidx])))
        c = 2 * np.pi - m * np.ones(self.n_faces)
        c = c / self.vertex_areas
        return c

    def get_average_vertex_rank(self):
        v = self.vertex_edge_adjacency.sum(axis=1).mean()
        print('average vertex rank = {}'.format(v))
        return v

    def average_face_to_vertex(self, data):
        return data * 1 / 3 * self.face_vertex_adjacency

    def average_vertex_to_face(self, data):
        ivf = sparse.eye(self.n_faces) * 1 / 3 * self.face_vertex_adjacency * sparse.eye(self.n_vertices)
        return data * ivf.T

    def get_boundary_faces(self):
        ff = self.edge_face_adjacency.T * self.edge_face_adjacency
        z = sparse.eye(self.n_faces)
        edge_faces = np.argwhere(ff.sum(0) == 5).T[1]
        self.add_poly_data(edge_faces, size=self.n_faces, name=EDGE_FACES)
        return edge_faces

    def get_boundary_edges(self):
        boundary_edges = np.argwhere(self.edge_face_adjacency.sum(1) == 1).T[0]
        self.boundary_edges = self.edges.T[boundary_edges]
        self.add_poly_data(np.ravel(self.boundary_edges), size=self.n_vertices, name=EDGE_VERTICES)
        return self.boundary_edges

    def add_poly_data(self, idxs, size, name, values=1):
        z = np.zeros(size)
        z[idxs] = values
        if size == self.n_faces:
            self.poly_data.cell_data[name] = z
        elif size == self.n_vertices:
            self.poly_data.point_data[name] = z
        else:
            print('data size = {} dose not fit n_points or n_faces'.format(size))
            raise
        self.poly_data.set_active_scalars(name)

    def plot(self, data_name = None):
        if data_name is not None:
            self.poly_data.set_active_scalars(data_name)
        self.poly_data.plot(show_edges=True)

    def plot_function(self, f, name = 'f'):
        self.poly_data[name] = f
        self.poly_data.set_active_scalars(name)
        self.poly_data.plot(show_edges=True)

    def plot_vectors(self, f, name='f'):
        pp = pv.Plotter()
        pp.add_mesh(self.poly_data, show_edges=True)
        if f.__len__() == self.n_faces:
            pp.add_arrows(self.face_centers, f, name = name)
        elif f.__len__() == self.n_vertices:
            pp.add_arrows(self.vertices, f, name = name)
        else:
            print('vectors dont fit mesh data')
            raise
        pp.show()

    def print(self, name: str = 'mesh'):
        print('{} Meta data'.format(name))
        print(' N Faces: {}'.format(self.n_faces))
        print(' N Vertices: {}'.format(self.n_vertices))
        print(' N Edges: {}'.format(self.n_edges))
        print(' N Boundary Edges: {}'.format(self.n_boundary_edges))
        print(' N Boundaries: {}'.format(self.n_boundaries))
        print(' N Genus: {}'.format(self.n_genus))
