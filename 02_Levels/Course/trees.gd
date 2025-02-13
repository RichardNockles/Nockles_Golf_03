extends MultiMeshInstance3D

@export var terrain: Node3D  # Assign `Masters_course_001` in the editor
@export var max_trees: int = 300  # Adjust tree density
@export var allowed_surfaces: Array = [1, 2]  # Material indices for tree placement
@export var tree_area: Vector3 = Vector3(100, 0, 100) # Area size for tree placement

var rng = RandomNumberGenerator.new()

func _ready():
    if not terrain or not terrain is MeshInstance3D:
        print("❌ Error: Terrain (Masters_course_001) not assigned or incorrect type!")
        return

    print("✅ Terrain Assigned:", terrain.name)
    print("✅ Allowed Surfaces:", allowed_surfaces)

    var physics_space = get_world_3d().direct_space_state
    var new_multimesh = MultiMesh.new()
    new_multimesh.transform_format = MultiMesh.TRANSFORM_3D
    new_multimesh.instance_count = max_trees
    multimesh = new_multimesh  # Assign the new MultiMesh

    var placed_trees = 0

    for i in range(max_trees):
        var position = Vector3(
            rng.randf_range(-tree_area.x, tree_area.x),
            10,  # Start slightly above the ground for Raycast
            rng.randf_range(-tree_area.z, tree_area.z)
        )

        # Perform Raycast downwards to detect ground
        var query = PhysicsRayQueryParameters3D.create(position, position - Vector3(0, 20, 0))
        var result = physics_space.intersect_ray(query)

        if result:
            var collider = result.collider
            if collider == terrain:  # Ensure we hit the terrain
                var material_index = result.shape  # Assuming shape index corresponds to surfaces

                print("🌿 Raycast hit surface index:", material_index)  # Debugging

                if material_index in allowed_surfaces:  # Place trees only on selected textures
                    var transform = Transform3D()
                    transform.origin = result.position

                    # Add random rotation and scale for natural placement
                    transform = transform.rotated(Vector3.UP, rng.randf_range(0, 2 * PI))
                    transform = transform.scaled(Vector3.ONE * rng.randf_range(0.8, 1.2))

                    multimesh.set_instance_transform(placed_trees, transform)
                    placed_trees += 1  # Only count successfully placed trees

    # Adjust final instance count to reflect the correct number of trees placed
    multimesh.instance_count = placed_trees
    print("✅ Successfully placed", placed_trees, "trees on the selected surfaces!")
