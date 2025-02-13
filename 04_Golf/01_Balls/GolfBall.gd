extends RigidBody3D

@export var hit_force: float = 20.0  # Base force for hitting
@export var max_power: float = 100.0  # Maximum power multiplier
@export var aim_speed: float = 2.0  # How fast the player can aim
@export var stop_threshold: float = 0.1  # Speed below which the ball stops moving

var aiming: bool = false
var power: float = 0.0
var camera_node: Node3D  # The camera that rotates when aiming

func _ready():
    print("🏌️ Golf Ball Ready!")
    freeze = true  # Ball is frozen until the player takes a shot
    camera_node = get_node_or_null("../Camera3D")  # Assuming the camera is a sibling in the scene

func _process(delta):
    if aiming:
        power = clamp(power + delta * max_power, 0, max_power)  # Charge up shot

    # Stop movement when very slow
    if linear_velocity.length() < stop_threshold:
        linear_velocity = Vector3.ZERO

func _input(event):
    # Start Aiming
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed:
            print("⛳ Aiming mode started...")
            aiming = true
            power = 0.0
        else:
            print("🏌️ Swing! Power:", power)
            hit_ball()
            aiming = false

    # Adjust Aiming Rotation
    if aiming and event is InputEventMouseMotion:
        if camera_node:
            camera_node.rotate_y(-event.relative.x * aim_speed * 0.001)  # Rotate the aim

func hit_ball():
    if power > 0:
        var direction = -global_transform.basis.z  # Forward direction of the ball
        apply_impulse(direction * power * hit_force)
        freeze = false  # Allow movement after hit
        power = 0.0  # Reset power after hitting
