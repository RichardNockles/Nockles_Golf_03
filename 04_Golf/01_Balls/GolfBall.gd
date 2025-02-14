extends RigidBody3D

@export var power_multiplier: float = 20.0  # Adjust shot power
@export var mouse_sensitivity: float = 0.2  # Adjust aiming speed
@export var camera_distance: float = 4.0  # Adjustable camera distance
@export var camera_height: float = 1.5  # Adjustable camera height
@export var charge_speed: float = 0.3  # Adjust shot power charge speed
@export var stop_threshold: float = 0.1  # Ball stops when below this speed
@export var max_trail_points: int = 50  # Max points in the ball trail

@onready var trail = $Line3D  # Ball trail effect
@onready var ball_camera = $BallCamera  # Camera following the ball

var is_aiming: bool = true
var is_moving: bool = false
var shot_power: float = 0.0

signal hole_completed  # Signal to notify Main.gd when a hole is completed

func _ready():
    print("🏌️ Golf Ball Ready!")
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED  # Lock cursor for aiming
    trail.clear_points()  # Ensure the trail is empty at start
    freeze = false  # Ensure ball is active at game start

func _unhandled_input(event):
    if is_aiming:
        if event is InputEventMouseMotion:
            # Rotate the ball (and camera) for aiming
            rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))

        if event.is_action_pressed("swing"):
            shot_power = 0.1  # Initialize power
        if event.is_action_released("swing"):
            hit_ball()

func _process(delta):
    if is_aiming and Input.is_action_pressed("swing"):
        shot_power = min(1.0, shot_power + delta * charge_speed)  # Charge shot power

func _physics_process(_delta):
    if is_moving:
        if linear_velocity.length() < stop_threshold:
            linear_velocity = Vector3.ZERO
            angular_velocity = Vector3.ZERO
            is_moving = false
            is_aiming = true
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
            trail.clear_points()

        # Camera follows the ball
        ball_camera.global_transform.origin = global_transform.origin + Vector3(0, camera_height, -camera_distance)
        ball_camera.look_at(global_transform.origin, Vector3.UP)

        # Ball Trail Effect
        trail.add_point(global_position)
        if trail.get_point_count() > max_trail_points:
            trail.remove_point(0)

func hit_ball():
    if is_aiming:
        print("🏌️ Hitting Ball! Power:", shot_power)
        is_aiming = false
        is_moving = true
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE  # Unlock mouse after hitting

        var direction = -transform.basis.z
        var force = shot_power * power_multiplier

        # Apply an impulse to the ball
        apply_impulse(direction * force)
        shot_power = 0.0
        freeze = false  # Ensure ball can move.

func _on_HoleTrigger_body_entered(body):
    if body == self:
        print("🏆 Ball in the hole!")
        hole_completed.emit()  # Notify Main.gd
        set_deferred("sleeping", true)  # Stop the ball
