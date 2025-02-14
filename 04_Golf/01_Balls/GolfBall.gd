extends RigidBody3D

@export var power_multiplier: float = 10.0  # Adjust shot power
@export var hit_force: float = 20.0  # Strength of the hit
@export var max_power: float = 100.0  # Max power charge
@export var stop_threshold: float = 0.1  # Ball stops when below this speed
@export var max_trail_points: int = 50  # Max points in the ball trail

@onready var trail = $Line3D  # Ball trail effect
@onready var main_scene = get_node_or_null("/root/Main")  # Reference to Main.tscn

var aiming: bool = false
var power: float = 0.0
var is_in_hole: bool = false
var is_moving: bool = false
var camera_node: Node3D
var hole_position: Vector3  # Position of the hole
var current_club: String = "Driver"  # Default club

func _ready():
    print("🏌️ Golf Ball Ready!")
    freeze = true  # Ball is frozen until the player takes a shot
    camera_node = get_node_or_null("../Camera3D")

    # Delay call to ensure `get_tree()` is ready
    call_deferred("_initialize_game")

func _initialize_game():
    if main_scene == null:
        main_scene = get_node("/root/Main")
    if main_scene == null:
        print("❌ Error: Main scene not found!")

func _process(delta):
    if aiming:
        power = clamp(power + delta * max_power, 0, max_power)  # Charge shot power

    if linear_velocity.length() < stop_threshold:
        is_moving = false
        linear_velocity = Vector3.ZERO

    # Update Trail Effect
    if is_moving:
        trail.add_point(global_transform.origin)
        if trail.get_point_count() > max_trail_points:
            trail.remove_point(0)  # Keep the trail length constant

    # Update distance to hole
    if hole_position:
        var distance_to_hole = global_transform.origin.distance_to(hole_position)
        current_club = select_club(distance_to_hole)  # Auto-select club

func _input(event):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed:
            print("⛳ Aiming mode started...")
            aiming = true
            power = 0.0
        else:
            print("🏌️ Swing! Power:", power)
            hit_ball()
            aiming = false

    if aiming and event is InputEventMouseMotion:
        if camera_node:
            camera_node.rotate_y(-event.relative.x * 0.001)  # Rotate the aim

func hit_ball():
    if power > 0:
        var direction = -global_transform.basis.z  # Forward direction of the ball
        var adjusted_force = adjust_power_for_club(power * hit_force)
        apply_impulse(direction * adjusted_force)
        freeze = false  # Allow movement after hit
        is_moving = true
        power = 0.0  # Reset power after hit

func _on_HoleTrigger_body_entered(body):
    if body == self:
        print("🏆 Ball in the hole!")
        is_in_hole = true
        freeze = true
        linear_velocity = Vector3.ZERO
        angular_velocity = Vector3.ZERO

        # Ask Main to move the ball to the next hole
        if main_scene:
            main_scene.call("move_to_next_hole")

func select_club(distance: float) -> String:
    if distance >= 200:
        return "Driver"
    elif distance >= 180:
        return "3-Wood"
    elif distance >= 170:
        return "5-Wood"
    elif distance >= 160:
        return "4-Hybrid"
    elif distance >= 150:
        return "5-Iron"
    elif distance >= 140:
        return "6-Iron"
    elif distance >= 130:
        return "7-Iron"
    elif distance >= 120:
        return "8-Iron"
    elif distance >= 110:
        return "9-Iron"
    elif distance <= 30:
        return "Putter"
    return "Wedge"  # Default fallback club

func adjust_power_for_club(base_power: float) -> float:
    match current_club:
        "Driver":
            return base_power * 1.2  # More power for Driver
        "3-Wood":
            return base_power * 1.1
        "5-Wood":
            return base_power * 1.0
        "4-Hybrid":
            return base_power * 0.9
        "5-Iron":
            return base_power * 0.85
        "6-Iron":
            return base_power * 0.8
        "7-Iron":
            return base_power * 0.75
        "8-Iron":
            return base_power * 0.7
        "9-Iron":
            return base_power * 0.65
        "Putter":
            return base_power * 0.4  # Lower power for putter
    return base_power  # Default power
