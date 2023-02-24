import json
import os
from enum import IntEnum

import numpy as np
import pyvista as pv
from scipy import sparse
from scipy.sparse import bsr_matrix, csr_matrix

from mesh import Mesh
from utils import rigid_transform_3D, read_off_file


class ToolStates(IntEnum):
    paint_support = 0
    paint_handel = 1
    transform = 2
    initial = 3


class ToolPaintColor(IntEnum):
    clear = 1
    handel = 2
    support = 3
    edge = 4


class HandelData:
    def __init__(self, box: pv.PolyData):
        self.box = box

    def update(self, box):
        c = self.box.center
        r, t = rigid_transform_3D(self.box.points, box.points)
        self.box = box.copy()
        return r, self.box.center - np.array(c)


class MeshTool:
    mesh: Mesh = None
    size_factor: float = None
    handle_points = np.array([])
    support_points = np.array([])
    sup_boundary_points = np.array([])
    h_boundary_points = np.array([])
    colored_cells = np.array([])
    boundary_cells = np.array([])
    handle_box: HandelData = None
    mesh_path = None
    D: bsr_matrix = None
    L: bsr_matrix = None
    wL: bsr_matrix = None

    L1 = None
    L2 = None
    edges = None
    support = None

    def __init__(self):
        self.plotter = pv.Plotter(lighting='three lights')
        light = pv.Light()
        light.set_direction_angle(90, 90)
        self.plotter.add_light(light)
        self.brush_size = 2
        self.order = 2
        self.smoothness = 1

        self.paint_color = ToolPaintColor.support
        self.tool_state: ToolStates = ToolStates.paint_support
        self.plotter: pv.Plotter = pv.Plotter()

    @property
    def is_initial(self):
        return True if self.tool_state is ToolStates.initial else False

    # callback
    def set_size(self, v):
        self.brush_size = v * self.size_factor

    # callback
    def set_smoothness(self, v):
        self.smoothness = v
        self.decompose_operator(update=False)
        self.deform()

    # callback
    def set_color(self, v=True):
        if self.is_initial:
            return
        self.tool_state = ToolStates.paint_support if self.tool_state != ToolStates.paint_support else ToolStates.paint_handel
        if self.tool_state == ToolStates.paint_support:
            self.paint_color = ToolPaintColor.support
            self.plotter.add_points(np.zeros(3), name='points_mesh', color='r')
        else:
            self.paint_color = ToolPaintColor.handel
            if self.handle_points.size > 0:
                self.plotter.add_points(self.mesh.vertices[self.handle_points], name='points_mesh', color='r', opacity=0.5)
        self.add_buttons()

    # callback
    def paint(self, point):
        if self.is_initial:
            return
        if self.tool_state == ToolStates.transform:
            return
        self.L1 = None
        self.L2 = None
        pids = self.mesh.find_points_within_radius(point, self.brush_size)
        self.set_points(pids, self.tool_state)

    # callback
    def setup_demo(self, v):
        # this code is used to record the demo and save it to a gif. it is meant to work on frog_s3.off
        # this is not meant to be run as part of the program and should be called instead of the "set_state" function
        self.box_widget = self.plotter.add_box_widget(self.transform, bounds=(0, 0, 0, 0, 0, 0), rotation_enabled=True, pass_widget=True)
        xyz = self.mesh.vertices[self.handle_points]
        x, y, z = np.min(xyz, axis=0)
        x1, y1, z1 = np.max(xyz, axis=0)
        self.box_widget.PlaceWidget((x, x1, y, y1, z, z1))
        box = pv.PolyData()
        self.box_widget.GetPolyData(box)
        self.handle_box = HandelData(box)
        self.set_smoothness(5.6)
        i = 0
        ii = 0
        self.plotter.open_gif("mesh.gif")
        self.plotter.clear_slider_widgets()
        self.plotter.clear_box_widgets()
        self.plotter.clear_button_widgets()
        self.clear_text()

        for i in range(30):
            s = -1 if i > 15 else 1
            box = box.rotate_x(s)
            self.transform(box, None)
            self.plotter.write_frame()

        c = box.center
        for i in range(80):
            s = 1 if i > 40 else -1
            box.points -= c
            box = box.rotate_z(s)
            box.points += c
            self.transform(box, None)
            self.plotter.write_frame()

        c = box.center
        x = np.array([0, 0.1, 0])
        for i in range(30):
            s = -1 if i > 20 else 1
            box.points = box.points + s * i * x
            self.transform(box, None)
            self.plotter.write_frame()

    # callback
    def set_state(self, v):
        if self.is_initial:
            return

        self.tool_state = ToolStates.transform if self.tool_state != ToolStates.transform else ToolStates.paint_support
        self.add_buttons()
        self.plotter.clear_slider_widgets()
        if self.tool_state == ToolStates.transform and self.handle_points.__len__() > 0:
            self.box_widget = self.plotter.add_box_widget(self.transform, bounds=(0, 0, 0, 0, 0, 0), rotation_enabled=True, pass_widget=True)
            xyz = self.mesh.vertices[self.handle_points]
            x, y, z = np.min(xyz, axis=0)
            x1, y1, z1 = np.max(xyz, axis=0)
            self.box_widget.PlaceWidget((x, x1, y, y1, z, z1))
            box = pv.PolyData()
            self.box_widget.GetPolyData(box)
            self.handle_box = HandelData(box)
            self.plotter.add_slider_widget(self.set_smoothness, [2.00001, 10], pointa=(.6, .9), pointb=(.9, .9), title='smoothness', event_type='end')
        else:
            self.plotter.clear_box_widgets()
            self.handle_box = None
            self.plotter.add_slider_widget(self.set_size, [2, 20], pointa=(.6, .9), pointb=(.9, .9), title='brush size')

    # callback
    def transform(self, box: pv.PolyData, widget=None):
        if self.is_initial:
            return
        if self.L1 is None:
            self.decompose_operator()
        if self.handle_points.__len__() != 0 and self.handle_box is not None:
            r, t = self.handle_box.update(box)
            tr_points = np.hstack([self.handle_points, self.h_boundary_points])
            center = np.mean(self.mesh.poly_data.points[tr_points], axis=0)
            points = (self.mesh.vertices[tr_points] - center) @ r.T + center + np.squeeze(t)
            self.mesh.set_vertices(tr_points, points)
            self.deform()

    # callback
    def set_order(self, v):
        self.order += 1
        if self.order > 3:
            self.order = 1
        self.plotter.add_title('state {}, K = {}'.format(self.tool_state.name, self.order), font_size=9)
        self.decompose_operator(update=False)
        self.deform()

    def save_painted_ids(self):
        if self.support_points.size == 0 or self.handle_points.size == 0:
            return
        fn = '{}_painted_ids.json'.format(os.path.basename(self.mesh_path).split('.')[0])
        path = os.path.join(os.path.dirname(self.mesh_path), fn)
        d = dict()
        d['support'] = self.support_points.tolist()
        d['handle'] = self.handle_points.tolist()
        with open(path, 'w') as out:
            json.dump(d, out)

    def load_painted_ids(self):
        if self.support_points.size > 0 or self.support_points.size > 0:
            return
        fn = '{}_painted_ids.json'.format(os.path.basename(self.mesh_path).split('.')[0])
        path = os.path.join(os.path.dirname(self.mesh_path), fn)
        with open(path, 'r') as fp:
            data = json.load(fp)
        self.support_points = np.array(data['support'])
        self.handle_points = np.array(data['handle'])
        self.set_points(self.support_points, ToolStates.paint_support)
        self.set_points(self.handle_points, ToolStates.paint_handel)

    def load(self, mesh_path: str):
        self.mesh_path = mesh_path
        vertices, faces, color = read_off_file(mesh_path)
        self.set_mesh(Mesh(faces=faces, vertices=vertices, color=color))

    def reload(self, v=True):
        self.save_painted_ids()
        self.load(self.mesh_path)
        self.reset_plotter()
        self.load_painted_ids()

    def set_mesh(self, mesh: Mesh):
        self.mesh = mesh
        self.mesh.poly_data.point_data['color'] = np.ones(self.mesh.n_vertices)

        self.size_factor = np.sqrt(self.mesh.face_areas.mean())
        self.handle_points = np.array([])
        self.support_points = np.array([])
        self.sup_boundary_points = np.array([])
        self.h_boundary_points = np.array([])
        self.colored_cells = np.array([])
        self.boundary_cells = np.array([])
        self.handle_box: HandelData = None

    def set_points(self, point_ids, state):
        color = np.zeros(self.mesh.n_vertices)
        color[point_ids] = self.paint_color
        cell_color = self.mesh.average_vertex_to_face(color)
        cids = np.where(cell_color == self.paint_color)[0]
        bids = np.where(np.logical_and(cell_color != 0, cell_color != self.paint_color))[0]
        self.colored_cells = np.unique(np.hstack([self.colored_cells, cids])).astype(int)
        self.boundary_cells = np.unique(np.hstack([self.boundary_cells, bids])).astype(int)
        self.boundary_cells = np.array([p for p in self.boundary_cells if p not in self.colored_cells]).astype(int)

        if state == ToolStates.paint_handel:
            self.mesh.poly_data.cell_data['cell_color'][cids] = ToolPaintColor.handel

            self.handle_points = np.unique(np.hstack([self.handle_points, point_ids])).astype(int)
            self.support_points = np.array([p for p in self.support_points if p not in self.handle_points]).astype(int)
            self.sup_boundary_points = np.array([p for p in self.sup_boundary_points if p not in self.handle_points]).astype(int)

            self.h_boundary_points = np.unique(np.hstack([self.h_boundary_points, self.mesh.face_points(bids)]))
            self.sup_boundary_points = np.array([p for p in self.sup_boundary_points if p not in self.h_boundary_points]).astype(int)
            self.h_boundary_points = np.array([p for p in self.h_boundary_points if p not in self.handle_points]).astype(int)

        if state == ToolStates.paint_support:
            self.mesh.poly_data.cell_data['cell_color'][cids] = ToolPaintColor.support
            self.support_points = np.unique(np.hstack([self.support_points, point_ids])).astype(int)
            self.handle_points = np.array([p for p in self.handle_points if p not in self.support_points]).astype(int)

            self.sup_boundary_points = np.unique(np.hstack([self.sup_boundary_points, self.mesh.get_boundary(point_ids, n=3)]))
            self.sup_boundary_points = np.array([p for p in self.sup_boundary_points if p not in self.support_points]).astype(int)
            self.sup_boundary_points = np.array([p for p in self.sup_boundary_points if p not in self.handle_points]).astype(int)

        self.add_main_mesh()

    def add_main_mesh(self, opacity=1):
        self.plotter.add_mesh(self.mesh.poly_data, name='mesh', cmap=['r', 'g', 'b'], pbr=True, metallic=0.8, roughness=0.5, diffuse=1., opacity=opacity)

    def decompose_operator(self, update=True):
        support_ids = np.hstack([self.support_points])
        handel_ids = np.hstack([self.handle_points, self.sup_boundary_points])

        all_idx = np.array(np.hstack([support_ids, handel_ids]))
        idx_ = dict(zip(all_idx, np.array(range(len(all_idx)))))

        numFree = support_ids.size
        numFixed = handel_ids.size
        l1_idx = []
        l1_values = []
        l2_idx = []
        l2_values = []

        L = self.get_L(update=update)[support_ids, :]
        for idx in np.array(L.nonzero()).T:
            if idx[1] not in all_idx:
                continue
            n = idx_[idx[1]]
            if idx[1] in support_ids:
                n1 = n
                l1_idx.append((idx[0], n1))
                l1_values.append(L[idx[0], idx[1]])
            else:
                n2 = n - numFree
                l2_idx.append([(idx[0], n2)])
                l2_values.append(L[idx[0], idx[1]])

        L1 = bsr_matrix((np.array(l1_values), np.squeeze(np.array(l1_idx).T)), shape=(numFree, numFree))
        L2 = bsr_matrix((np.array(l2_values), np.squeeze(np.array(l2_idx).T)), shape=(numFree, numFixed))

        self.L1 = L1
        self.L2 = L2

    def get_L(self, update=True):
        if update or self.L is None or self.wL is None:
            self.L = self.mesh.cot_weights()
            self.wL = 0.25 * self.mesh.Gv(inverse=True) * self.L

        if self.order == 1:
            return self.wL
        if self.order == 2:
            D = self.get_D(smoothness=self.smoothness)
            return csr_matrix(self.L * D * self.wL)
        if self.order == 3:
            D = self.get_D(smoothness=self.smoothness)
            l2 = self.L * D * self.wL
            return csr_matrix(self.L * D * l2)

    def get_D(self, smoothness=0.5):
        eye = csr_matrix(sparse.eye(self.mesh.n_vertices))
        z = smoothness * np.ones(self.mesh.n_vertices)
        handel_ids = np.hstack([self.sup_boundary_points])
        z[handel_ids] = smoothness - self.order
        z = np.clip(z, 0, smoothness)
        eye.setdiag(z)
        return eye

    def deform(self):
        support_ids = np.hstack([self.support_points])
        handel_ids = np.hstack([self.handle_points, self.sup_boundary_points])
        bid = np.hstack(handel_ids)
        b = -1 * self.L2 * self.mesh.vertices[bid]
        x = sparse.linalg.spsolve(A=csr_matrix(self.L1), b=b)
        self.mesh.set_vertices(support_ids, x)
        self.plotter.update()

    def add_buttons(self, initial=False):
        self.plotter.clear_button_widgets()
        self.plotter.update() if not initial else False
        base = 10.0
        text = 55.0
        self.plotter.add_title('state {}'.format(self.tool_state.name), font_size=9)
        self.plotter.add_text('', name='color_title', position=(10., base + text), font_size=5)

        if self.tool_state != ToolStates.transform:
            t = 'paint support' if self.paint_color == ToolPaintColor.support else 'paint handle'
            t = '{} (value = {})'.format(t, self.paint_color)
            self.plotter.add_text(t, name='color_title', position=(10., base + text), font_size=5)
            self.plotter.add_checkbox_button_widget(self.set_color, position=(10., base))

        else:
            self.plotter.add_title('state {}, K = {}'.format(self.tool_state.name, self.order), font_size=9)
            self.plotter.add_text('set order', name='order', position=(10., base + text), font_size=5)
            self.plotter.add_checkbox_button_widget(self.set_order, position=(10., base))

        base += 90
        self.plotter.add_text('set state', name='state', position=(10., base + text), font_size=5)
        self.plotter.add_checkbox_button_widget(self.set_state, position=(10., base))

        base += 90
        self.plotter.add_text('reset', name='reset', position=(10., base + text), font_size=5)
        self.plotter.add_checkbox_button_widget(self.reload, position=(10., base))

    def setup_picker(self):
        self.plotter.iren.track_click_position(self.paint, side="left")

    def setup_plotter(self):
        print('setting up plotter')
        self.mesh.poly_data.cell_data['cell_color'] = ToolPaintColor.clear * np.ones(self.mesh.n_faces)
        self.mesh.poly_data.set_active_scalars('cell_color')
        self.add_main_mesh()
        self.plotter.add_slider_widget(self.set_size, [2, 100], pointa=(.6, .9), pointb=(.9, .9), title='brush size')

        self.add_buttons(initial=True)
        self.setup_picker()

    def reset_plotter(self):
        self.add_main_mesh()
        self.plotter.add_points(np.zeros(3), name='points_mesh')
        self.plotter.add_points(np.zeros(3), name='h_boundary_points_mesh')
        self.plotter.add_points(np.zeros(3), name='handle_points_mesh')
        self.plotter.add_points(np.zeros(3), name='s_boundary_points_mesh')
        self.plotter.clear_box_widgets()
        self.handle_box = None
        self.load(self.mesh_path)
        self.setup_plotter()

    def clear_text(self):
        self.plotter.add_text('', name='color_title')
        self.plotter.add_text('', name='state')
        self.plotter.add_text('', name='order')
        self.plotter.add_text('', name='set_order')
        self.plotter.add_text('', name='reset')
        self.plotter.add_title('Demo, mesh deformation tool (Yissachar, Manor)', font_size=5)

    def show(self):
        self.setup_plotter()
        self.plotter.show()


def run_mesh_tool(mesh_off_file: str):
    assert os.path.exists(mesh_off_file), '{} file not found'.format(mesh_off_file)
    tool = MeshTool()
    tool.load(mesh_off_file)
    tool.show()


if __name__ == '__main__':
    data_folder = r'data'
    frog_file = os.path.join(data_folder, 'frog_s3.off')
    run_mesh_tool(frog_file)
