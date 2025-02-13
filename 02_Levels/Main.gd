extends Node3D

@onready var course_scene_instance = preload("res://02_Levels/Course/Course.tscn").instantiate() # Assuming you are using 'Course.tscn' now

func _ready():
    add_child(course_scene_instance) # Instance and add Course.tscn as a child of Main

    # You can add any other scene-level setup code here in _ready() if needed in the future.
    # For example, game initialization, UI setup, etc.
    # For now, it's just instancing the Course.tscn.
