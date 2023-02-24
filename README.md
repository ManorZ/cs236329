# cs236329 at the Technion - Israel Institute of Technology

**an implementation in python based on [An Intuitive Framework for Real-Time Freeform Modeling Implementation](https://github.com/ManorZ/cs236329/blob/project/docs/An%20Intuitive%20Framework%20for%20Real-Time%20Freeform%20Modeling.pdf)**
![Demo](https://github.com/ManorZ/cs236329/blob/project/data/plots_mesh_tool/mesh_demo.gif)

## Introduction

This report summarizes our work to implement the 2004 paper “An Intuitive Framework for Real-Time Freeform Modeling Implementation”.
Our implementation is written in Python and provides a GUI-based application for real-time manipulation of triangle meshes.
The fundamental problem this work thrives to solve is that freeform deformation of meshes is an extremely high-dimensional problem. The designer explores the problem space using only clicking & dragging 2D positions on the screen.
Therefore, an exact (in terms of deformation outcome) yet abstract (in terms of UI) control metaphor is needed.
Moreover, we require this controlling metaphor to be fast (real-time!), so the designer could perform multiple online steps, observe some visual feedback, and decide on the next step during the design process.
In our implementation and UI design, we followed the principles defined in the paper, both mathematically and in terms of user control metaphors.

## Setup

```commandline
git clone https://github.com/ManorZ/cs236329.git
cd cs236329
pip install -r requirements.txt
python src/mesh_tool.py
```