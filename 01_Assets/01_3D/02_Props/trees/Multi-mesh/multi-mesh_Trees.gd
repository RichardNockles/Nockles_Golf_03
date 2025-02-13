extends MultiMeshInstance3D

@export var tree_mesh : Mesh
@export var bush_mesh : Mesh
@export var num_trees = 500
@export var num_bushes = 300
@export var area_size = 100.0
@export var landscape_mesh_path : NodePath = NodePath("Masters_course/Course_Mesh/LandscapeMeshInstance") # Updated path to LandscapeMeshInstance (assuming you added it)
@export var allowed_tree_textures = ["High Ground"] # Allowed textures for trees - update in Inspector!
@export var allowed_bush_textures = ["High Ground"] # Allowed textures for bushes - update in Inspector!


var landscape_mesh : MeshInstance3D # Variable to hold the landscape mesh node

func _ready():
    randomize()

    # Get the landscape mesh node using the NodePath from the Inspector
    landscape_mesh = get_node(landscape_mesh_path)
    if landscape_mesh == null:
        printerr("Error: Landscape mesh not found at path: ", landscape_mesh_path)
        return # Stop if landscape mesh is not found

    multimesh.instance_count = num_trees + num_bushes

    # Set up tree instances
    for i in range(num_trees):
        var x = randf_range(-area_size / 2.0, area_size / 2.0)
        var z = randf_range(-area_size / 2.0, area_size / 2.0)
        var y = 0.0 # Initial Y, will be adjusted by raycast

        var instance_pos = Vector3(x, y, z) # Renamed 'pos' to 'instance_pos'

        if is_texture_allowed_at_position(instance_pos, allowed_tree_textures): # Use 'instance_pos'
            # Texture is allowed, place the tree
            var rotation_y = randf_range(0, TAU)
            var rotation_quat = Quaternion(Vector3.UP, rotation_y)
            var instance_scale = Vector3.ONE * randf_range(0.8, 1.2) # Renamed 'scale' to 'instance_scale'

            var instance_transform = Transform3D() # Renamed 'transform' to 'instance_transform'
            instance_transform.origin = instance_pos # Use 'instance_pos'
            instance_transform.basis = Basis(rotation_quat)
            instance_transform.scale = instance_scale # Use 'instance_scale'

            multimesh.set_instance_transform(i, instance_transform) # Use 'instance_transform'
            multimesh.set_instance_mesh(i, tree_mesh)
        else:
            # Texture not allowed, hide the instance
            multimesh.set_instance_transform(i, Transform3D.IDENTITY)
            multimesh.set_instance_mesh(i, null)


    # Set up bush instances
    for i in range(num_bushes):
        var x = randf_range(-area_size / 2.0, area_size / 2.0)
        var z = randf_range(-area_size / 2.0, area_size / 2.0)
        var y = 0.0 # Initial Y, will be adjusted by raycast

        var instance_pos = Vector3(x, y, z) # Renamed 'pos' to 'instance_pos'

        if is_texture_allowed_at_position(instance_pos, allowed_bush_textures): # Use 'instance_pos'
            # Texture is allowed, place the bush
            var rotation_y = randf_range(0, TAU)
            var rotation_quat = Quaternion(Vector3.UP, rotation_y)
            var instance_scale = Vector3.ONE * randf_range(0.5, 0.9) # Renamed 'scale' to 'instance_scale'

            var instance_transform = Transform3D() # Renamed 'transform' to 'instance_transform'
            instance_transform.origin = instance_pos # Use 'instance_pos'
            instance_transform.basis = Basis(rotation_quat)
            instance_transform.scale = instance_scale # Use 'instance_scale'

            multimesh.set_instance_transform(num_trees + i, instance_transform) # Use 'instance_transform'
            multimesh.set_instance_mesh(num_trees + i, bush_mesh)
        else:
            # Texture not allowed, hide the instance
            multimesh.set_instance_transform(num_trees + num_bushes + i, Transform3D.IDENTITY) # Hide instance
            multimesh.set_instance_mesh(num_trees + num_bushes + i, null)


# **--- Texture Check Function ---**
func is_texture_allowed_at_position(check_position, allowed_texture_names): # <--- Parameter is now 'check_position'
    if landscape_mesh == null:
        return false

    var space_state = get_world_3d().get_direct_space_state()
    var query = PhysicsRayQueryParameters3D.new()
    query.from = check_position + Vector3.UP * 100.0 # Use 'check_position'
    query.to = check_position + Vector3.DOWN * 100.0 # Use 'check_position'
    query.collide_mask = 1
    query.collision_layer = 1
    query.exclude = [self]

    var result = space_state.intersect_ray(query)

    if result and result.collider == landscape_mesh:
        var mesh = landscape_mesh.mesh
        var surface_index = 0 # Assuming single surface (index 0)
        var material_index = mesh.surface_get_polygon_material(surface_index, result.face_index) # Get material index

        var material = null

        if mesh.material is Array: # Check if mesh.material is an Array
            if material_index >= 0 and material_index < mesh.material.size():
                material = mesh.material[material_index] # Get material from array
        # else if mesh.material_override is Array: # Uncomment this block if materials are in material_override instead
        #     if material_index >= 0 and material_index < mesh.material_override.size():
        #         material = mesh.material_override[material_index]


        if material:
            var material_name = material.name
            if material_name in allowed_texture_names:
                return true
    return false
