extends KinematicBody2D
tool

onready var tween = get_node("tween")

enum Orientation {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

export (Orientation) var orientation = Orientation.UP;

var rotating = 0
var rotation_time = 5 # seconds

func _orientation_to_degrees(o):
	match o:
		UP: return 0
		DOWN: return 180
		LEFT: return -90
		RIGHT: return 90

func _ready():
	pass

func _process(delta):
	rotation_degrees = _orientation_to_degrees(orientation)