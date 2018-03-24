extends KinematicBody2D
tool

enum Orientation {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

export (Orientation) var orientation = Orientation.UP;

onready var tween = get_node("tween")

var ROTATION_TIME = 1 # seconds
var rotating = false

func _orientation_to_degrees(o):
	match o:
		UP: return 0
		DOWN: return 180
		LEFT: return -90
		RIGHT: return 90

func _ready():
	if not Engine.editor_hint:
		get_node("/root/Game").connect("on_level_step_end", self, "_on_level_end_turn")
		tween.connect("tween_completed", self, "_on_platform_rotation_end")

func _on_platform_rotation_end(obj, key):
	pass

func _on_level_end_turn():
	tween.interpolate_property(self, "rotation_degrees", rotation_degrees, rotation_degrees + 90, ROTATION_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN) 

func _process(delta):
	rotation_degrees = _orientation_to_degrees(orientation)