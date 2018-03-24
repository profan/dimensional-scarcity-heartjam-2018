extends Area2D
tool

enum Orientation {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

export (Orientation) var orientation = Orientation.UP;

onready var tween = get_node("tween")
onready var coll = get_node("main_coll")
onready var left_area = get_node("left_area")
onready var right_area = get_node("right_area")

var ROTATION_TIME = 1 # seconds
var rotating = false

func _orientation_to_degrees(o):
	match o:
		UP: return 0
		DOWN: return 180
		LEFT: return -90
		RIGHT: return 90

func _degrees_to_orientation(d):
	var f = round(d)
	if f== 0 or f == 360:
		return UP
	elif f == 180 or f == -180:
		return DOWN
	elif f == -90 or f == 270:
		return LEFT
	elif f == 90 or f == -270:
		return RIGHT

func _ready():
	if not Engine.editor_hint:
		
		var g = get_node("/root/Game")
		g.connect("on_level_step_end", self, "_on_level_end_turn")
		tween.connect("tween_completed", self, "_on_platform_rotation_end")
		g.register_platform(self)
		
		connect("body_entered", self, "_on_body_enter_platform")
		
		left_area.connect("body_entered", self, "_on_body_enter_left")
		left_area.connect("body_exited", self, "_on_body_exit_left")
		right_area.connect("body_entered", self, "_on_body_enter_right")
		right_area.connect("body_exited", self, "_on_body_exit_right")

func _on_body_enter_platform(b):
	if b.get_parent() != self:
		b.do_crouch()

func _on_body_enter_left(b):
	b.current_side = "left"
	print("ENTERO LEFT")

func _on_body_exit_left(b):
	b.current_side = null
	b.last_side = "left"
	print("EXIT LEFT")

func _on_body_enter_right(b):
	b.current_side = "right"
	print("ENTERO RIGHT")

func _on_body_exit_right(b):
	b.current_side = null
	b.last_side = "right"
	print("EXIT RIGHT")

func _on_platform_rotation_end(obj, key):
	orientation = _degrees_to_orientation(rotation_degrees)
	tween.stop_all()

func _on_level_end_turn():
	var g = get_node("/root/Game")
	tween.interpolate_property(self, "rotation_degrees", rotation_degrees, rotation_degrees + g.turn_rotation, ROTATION_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()

func _process(delta):
	if not Engine.editor_hint and not tween.is_active():
		rotation_degrees = _orientation_to_degrees(orientation)