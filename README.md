# voxel-symmetry
Octahedral symmetry for voxel geometry.

# What is octahedral symmetry?
https://en.wikipedia.org/wiki/Octahedral_symmetry

The above wiki will give you a general overview, but it won't do
help you understand it very much without a mathematics education.
The basic gist is that octahedral symmetry describes the operations
and relationships between the 24 and 48 element groups of rotations
and symmetries (rotations with inversion) of an axis-aligned cube
(or octahedron).

The 24 element group is called the chiral octahedral symmetry group.
It describes the 24 orientation preserving rotations. To explain
this, I will describe an axis-aligned cube that is defined by its Up
vector, and its rotation around that Up vector. For each of the 6
faces of a cube, there are 4 rotations.

The 48 element group is a bit easier. It's the initial 24 rotations,
but with an additional 24 "symmetries" that represent inversions of
the 24 rotations. These inversions would be the rotation with all
axes inverted. Up becomes Down, Left becomes Right, Forward becomes
Backward.

# Terminology
- **Axial**: The positive and negative vectors along the X, Y, and Z axes.
- **Face**: The 6 cardinal directions of 3D space (Up/Down/Left/Right/Forward/Backward).
- **Rot (Rotation)**: The chiral octahedral symmetry group (24 elements).
- **Sym (Symmetry)**: The achiral octahedral symmetry group (48 elements).
