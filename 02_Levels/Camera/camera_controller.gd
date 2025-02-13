extends Camera3D

@export var move_speed: float = 5.0  # Movement speed
@export var mouse_sensitivity: float = 0.002  # Mouse rotation sensitivity
@export var rotation_damping_factor: float = 0.9  # Smooth rotation stopping

var movement_vector: Vector3 = Vector3.ZERO
var rotation_vector: Vector2 = Vector2.ZERO
var rotation_velocity: Vector2 = Vector2.ZERO
var is_mouse_button_pressed: bool = false  # Track if left mouse button is pressed

func _ready():
    Input.mouse_mode = Input.MOUSE_MODE_CONFINED  # Keep cursor visible but inside window

func _process(delta):
    movement_vector = Vector3.ZERO  # Reset movement every frame

    # **Corrected Camera-Relative Movement**
    if Input.is_action_pressed("move_forward"):
        movement_vector += -transform.basis.z  # Move forward relative to camera
    if Input.is_action_pressed("move_backward"):
        movement_vector += transform.basis.z  # Move backward relative to camera
    if Input.is_action_pressed("move_left"):
        movement_vector += -transform.basis.x  # Move left relative to camera
    if Input.is_action_pressed("move_right"):
        movement_vector += transform.basis.x  # Move right relative to camera
    if Input.is_action_pressed("move_up"):
        movement_vector += Vector3.UP  # Move up (global up)
    if Input.is_action_pressed("move_down"):
        movement_vector -= Vector3.UP  # Move down (global down)

    # Normalize and apply movement
    if movement_vector.length() > 0:
        movement_vector = movement_vector.normalized() * move_speed * delta
        global_transform.origin += movement_vector  # Use global_transform.origin instead of translate_object_local()

    # **Mouse Look (Yaw & Pitch)**
    if is_mouse_button_pressed:
        rotation_velocity = rotation_vector * mouse_sensitivity * delta * 1000
    else:
        rotation_velocity *= rotation_damping_factor  # Smoothly stop rotation

    # Apply camera rotation
    rotate_y(rotation_velocity.x)  # Yaw (left/right rotation)
    # rotate_x(rotation_velocity.y)  # Pitch (optional vertical rotation, currently disabled)

    # Reset rotation input
    rotation_vector = Vector2.ZERO

    # Quit game if Escape key is pressed
    if Input.is_action_just_pressed("ui_cancel"):
        get_tree().quit()

func _input(event):
    if event is InputEventMouseMotion and is_mouse_button_pressed:
        rotation_vector.x = -event.relative.x  # Mouse horizontal movement (yaw)
        rotation_vector.y = event.relative.y  # Mouse vertical movement (pitch)

    # Handle Mouse Button Events
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        is_mouse_button_pressed = event.pressed
