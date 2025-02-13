extends MultiMeshInstance3D

@export var terrain: MeshInstance3D  # Assign `Masters_course_001` in the editor
@export var max_trees: int = 300  # Number of trees to place
@export var max_bushes: int = 200  # Number of bushes to place
@export var allowed_tree_textures: Array = ["Surface_1", "Surface_2"]  # Corrected Material Names
@export var allowed_bush_textures: Array = ["Surface_1", "Surface_2"]  # Corrected Material Names
@export var tree_area: Vector3 = Vector3(100, 0, 100)  # Define placement boundaries
@export var height_offset: float = 1.5  # Adjust this to raise trees slightly above the ground

var rng = RandomNumberGenerator.new()

func _ready():
    if not terrain or not terrain is MeshInstance3D:
        print("❌ Error: Terrain not assigned or incorrect type!")
        return

    print("✅ Terrain Assigned:", terrain.name)
    print("✅ Allowed Tree Surfaces:", allowed_tree_textures)
    print("✅ Allowed Bush Surfaces:", allowed_bush_textures)

    var physics_space = get_world_3d().direct_space_state
    var new_multimesh = MultiMesh.new()
    new_multimesh.transform_format = MultiMesh.TRANSFORM_3D
    new_multimesh.instance_count = max_trees + max_bushes
    multimesh = new_multimesh  # Assign the new MultiMesh

    var placed_trees = 0
    var placed_bushes = 0

    for i in range((max_trees + max_bushes) * 2):  # More attempts for better coverage
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
                var material_name = get_material_name(result.shape)

                print("🌿 Raycast hit surface:", material_name, "at", result.position)  # Debugging

                if material_name in allowed_tree_textures and placed_trees < max_trees:
                    place_instance(placed_trees, result.position, "tree")
                    placed_trees += 1

                elif material_name in allowed_bush_textures and placed_bushes < max_bushes:
                    place_instance(max_trees + placed_bushes, result.position, "bush")
                    placed_bushes += 1

                if placed_trees >= max_trees and placed_bushes >= max_bushes:
                    break  # Stop when reaching the limit

    # Adjust final instance count to reflect the correct number of objects placed
    multimesh.instance_count = placed_trees + placed_bushes
    print("✅ Successfully placed", placed_trees, "trees and", placed_bushes, "bushes on the selected surfaces!")

func get_material_name(material_index) -> String:
    if material_index >= 0 and material_index < terrain.mesh.get_surface_count():
        return terrain.mesh.surface_get_material(material_index).resource_name
    return "Unknown"

func place_instance(index: int, position: Vector3, instance_type: String):
    var transform = Transform3D()
    transform.origin = position + Vector3(0, height_offset, 0)  # 🔹 Raise the object slightly above ground

    # Add random rotation and scale for natural placement
    transform = transform.rotated(Vector3.UP, rng.randf_range(0, 2 * PI))

    if instance_type == "tree":
        transform = transform.scaled(Vector3.ONE * rng.randf_range(1.0, 3.0))  # Scale trees
    else:
        transform = transform.scaled(Vector3.ONE * rng.randf_range(0.5, 1.5))  # Scale bushes

    multimesh.set_instance_transform(index, transform)
