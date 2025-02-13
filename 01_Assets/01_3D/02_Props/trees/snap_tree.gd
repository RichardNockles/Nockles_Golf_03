extends Node3D

@export var terrain: Node3D  # Assign `Masters_course_001` (the terrain) here

func _ready():
    if not terrain:
        print("❌ Error: Terrain not assigned!")
        return

    print("✅ Snapping trees to the terrain...")
    
    var physics_space = get_world_3d().direct_space_state

    for tree in get_children():
        if not tree is MeshInstance3D:
            continue  # Skip non-mesh objects

        var tree_pos = tree.global_transform.origin
        var ray_start = tree_pos + Vector3(0, 5, 0)  # Start slightly above
        var ray_end = tree_pos + Vector3(0, -50, 0)  # Cast downward

        var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
        var result = physics_space.intersect_ray(query)

        if result and result.collider == terrain:
            tree.global_transform.origin.y = result.position.y
            print("🌳 Snapped", tree.name, "to", result.position.y)
        else:
            print("⚠️ Could not find terrain for", tree.name)
