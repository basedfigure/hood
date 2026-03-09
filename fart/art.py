bl_info = {
    "name": "Art file save",
    "blender": (2, 74, 0),
    "category": "Import-Export",
}

import bpy
import bpy_extras.io_utils
import struct

def export_mesh_data(filepath, mesh):
    try:
        with open(filepath, 'wb') as f:
            # Writes the sector name MESH
            f.write(b'MESH')

            f.write(struct.pack('i', len(mesh.vertices)))
            f.write(struct.pack('i', len(mesh.tessfaces)))

            # Writes the vertex positions and normals
            for vertex in mesh.vertices:
                f.write(struct.pack('fff', *vertex.co))
                f.write(struct.pack('fff', *vertex.normal))

            for tessface in mesh.tessfaces:
                indices = len(tessface.vertices)
                f.write(struct.pack('i', indices))
                for idx in tessface.vertices:
                    f.write(struct.pack('i', idx))

            uv_layer = mesh.tessface_uv_textures.active
            if not uv_layer:
                print("Gah! Active UV layer is not set.")
                return False

            # Writes the sector name VMAP
            f.write(b'VMAP')
            f.write(struct.pack('i', len(mesh.tessfaces)))

            for tessface in mesh.tessfaces:
                uv_data = uv_layer.data[tessface.index]
                for i, vertex_index in enumerate(tessface.vertices):
                    vertex = mesh.vertices[vertex_index]
                    uv = uv_data.uv[i]
                    f.write(struct.pack('i', vertex_index))
                    f.write(struct.pack('fff', *vertex.co))
                    f.write(struct.pack('ff', uv[0], uv[1]))

        print("Hah, success!")
        return True
    except Exception as e:
        print("Gah, it failed!: " + str(e))
        return False

class ExportMeshData(bpy.types.Operator, bpy_extras.io_utils.ExportHelper):
    '''Export Mesh Sector to an ART file'''
    bl_idname = "export_mesh.art"
    bl_label = 'Save ART'
    filename_ext = ".art"

    def execute(self, context):
        obj = context.active_object
        mesh = obj.data

        if not mesh.uv_textures:
            self.report({'ERROR'}, "Gah, no UVs made! First run Smart UV Project and then seamsfromislands.py script, if you just want to save an art file.")
	    #
	    # Note (2026-3-9):  seamsfromislands.py does not exist anymore, just create your UVs by hand, like a good 3D artist.
	    #
            return {'CANCELLED'}

        mesh.update(calc_tessface=True)

        if not export_mesh_data(self.filepath, mesh):
            self.report({'ERROR'}, "Failure")
            return {'CANCELLED'}

        self.report({'INFO'}, "Success")
        return {'FINISHED'}

def register():
    bpy.utils.register_class(ExportMeshData)

def unregister():
    bpy.utils.unregister_class(ExportMeshData)

if __name__ == "__main__":
    register()
