extends Camera3D

@export var move_speed: float = 5.0
@export var mouse_sensitivity: float = 0.0005
@export var rotation_damping_factor: float = 0.85

var movement_vector: Vector3 = Vector3.ZERO
var rotation_vector: Vector2 = Vector2.ZERO
var rotation_velocity: Vector2 = Vector2.ZERO
var is_mouse_button_pressed: bool = false

func _ready():
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _process(delta):
    # Movement Input (WASD keys now move in WORLD directions)
    movement_vector = Vector3.ZERO

    var world_forward = Vector3.FORWARD
    var world_backward = Vector3.BACK
    var world_left = Vector3.LEFT
    var world_right = Vector3.RIGHT
    var world_up = Vector3.UP
    var world_down = Vector3.DOWN

    # Rotate world movement vectors by camera's Y-rotation (yaw)
    var camera_yaw_rotation = Basis.IDENTITY.rotated(Vector3.UP, rotation.y)

    if Input.is_action_pressed("move_forward"):
        movement_vector += camera_yaw_rotation.xform_vector(world_forward)
    if Input.is_action_pressed("move_backward"):
        movement_vector += camera_yaw_rotation.xform_vector(world_backward)
    if Input.is_action_pressed("move_left"):
        movement_vector += camera_yaw_rotation.xform_vector(world_left)
    if Input.is_action_pressed("move_right"):
        movement_vector += camera_yaw_rotation.xform_vector(world_right)
    if Input.is_action_pressed("move_up"):
        movement_vector += world_up
    if Input.is_action_pressed("move_down"):
        movement_vector += world_down


    movement_vector = movement_vector.normalized() * move_speed * delta
    translate_object_local(movement_vector)

    # Rotation (Mouse look ONLY when left mouse button is pressed) - Horizontal only (yaw), Dampened Rotation
    if is_mouse_button_pressed:
        rotate_y(rotation_velocity.x * mouse_sensitivity * delta * 1000)
        # rotate_x(rotation_velocity.y * mouse_sensitivity * delta * 1000)  # Vertical rotation (pitch) COMMENTED OUT

    rotation_vector = Vector2.ZERO
    rotation_velocity *= rotation_damping_factor

    # Check for Escape key to quit
    if Input.is_action_just_pressed("ui_cancel"):
        get_tree().quit()

func _input(event):
    if event is InputEventMouseMotion:
        rotation_vector.x += -event.relative.x
        rotation_vector.y += event.relative.y

    # Handle Mouse Button Events
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        is_mouse_button_pressed = event.pressed
