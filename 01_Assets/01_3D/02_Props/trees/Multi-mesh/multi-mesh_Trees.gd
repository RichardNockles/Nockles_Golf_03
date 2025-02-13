extends MultiMeshInstance3D

@export var terrain: MeshInstance3D  # Assign `Masters_course_001` in the editor
@export var max_trees: int = 300  # Number of trees to place
@export var max_bushes: int = 200  # Number of bushes to place
@export var allowed_tree_textures: Array = ["Fairway_02.001", "High Ground.001"]
@export var allowed_bush_textures: Array = ["Fairway_02.001", "High Ground.001"]
@export var tree_area: Vector3 = Vector3(100, 0, 100)  # Define placement boundaries
@export var height_offset: float = 2.0  # Raise trees above the ground

var rng = RandomNumberGenerator.new()

func _ready():
    if not terrain or not terrain is MeshInstance3D:
        print("❌ Error: Terrain not assigned or incorrect type!")
        return

    print("✅ Terrain Assigned:", terrain.name)

    # Print ALL material names
    var detected_materials = []
    for i in range(terrain.mesh.get_surface_count()):
        var material = terrain.mesh.surface_get_material(i)
        if material:
            print("🔍 Detected Material:", material.resource_name)
            detected_materials.append(material.resource_name)

    print("✅ All Detected Materials on Terrain:", detected_materials)

    var physics_space = get_world_3d().direct_space_state
    var new_multimesh = MultiMesh.new()
    new_multimesh.transform_format = MultiMesh.TRANSFORM_3D
    new_multimesh.instance_count = max_trees + max_bushes
    multimesh = new_multimesh  # Assign the new MultiMesh

    var placed_trees = 0
    var placed_bushes = 0

    for i in range(max_trees * 3):  # More attempts to improve placement
        var spawn_pos = Vector3(
            rng.randf_range(-tree_area.x, tree_area.x),
            10,  # Start slightly above the ground for Raycast
            rng.randf_range(-tree_area.z, tree_area.z)
        )

        # Perform Raycast downwards to detect ground
        var query = PhysicsRayQueryParameters3D.create(spawn_pos, spawn_pos - Vector3(0, 50, 0))
        var result = physics_space.intersect_ray(query)

        if result:
            var collider = result.collider
            if collider == terrain:
                var material_name = get_material_name(result.shape)

                print("🌿 Raycast hit:", result.position, "| Object:", collider.name, "| Material:", material_name)

                if material_name in allowed_tree_textures and placed_trees < max_trees:
                    print("✅ Material Matched for Tree Placement:", material_name)
                    place_instance(placed_trees, result.position)
                    placed_trees += 1

                elif material_name in allowed_bush_textures and placed_bushes < max_bushes:
                    print("✅ Material Matched for Bush Placement:", material_name)
                    place_instance(max_trees + placed_bushes, result.position)
                    placed_bushes += 1

                if placed_trees >= max_trees and placed_bushes >= max_bushes:
                    break  # Stop when reaching the limit

    # Adjust final instance count
    multimesh.instance_count = placed_trees + placed_bushes
    print("✅ Successfully placed", placed_trees, "trees and", placed_bushes, "bushes!")

    # TEST: Force a tree to spawn at a fixed position for debugging
    place_instance(0, Vector3(0, 5, 0))
    print("🛠️ Test: Forced tree placement at (0,5,0)")

func get_material_name(material_index) -> String:
    if material_index >= 0 and material_index < terrain.mesh.get_surface_count():
        var material = terrain.mesh.surface_get_material(material_index)
        if material:
            print("🔍 Detected Material:", material.resource_name)
            return material.resource_name
    return "Unknown"

func place_instance(index: int, spawn_position: Vector3):
    var instance_transform = Transform3D()
    instance_transform.origin = spawn_position + Vector3(0, height_offset, 0)  # Raise the object slightly

    instance_transform = instance_transform.rotated(Vector3.UP, rng.randf_range(0, 2 * PI))
    instance_transform = instance_transform.scaled(Vector3.ONE * rng.randf_range(1.0, 3.0))  # Scale trees

    multimesh.set_instance_transform(index, instance_transform)
