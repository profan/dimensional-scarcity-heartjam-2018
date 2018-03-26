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

var ROTATION_TIME = 0.5 # seconds
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

func type():
	return "platform"

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
	if b.get_parent() != self and b.has_method("do_crouch"):
		b.do_crouch()

func _on_body_enter_left(b):
	if b.type() == "player" and (b.get_parent().type() != "platform" or not b.current_side):
		b.current_side = "left"
		print("ENTERO LEFT")
		if get_child_count() >= 7:
			b.connect("before_player_finished_move", self, "_before_player_finished_moving", [], CONNECT_ONESHOT)
			b.connect("player_finished_move", self, "_on_player_finished_moving", [], CONNECT_ONESHOT)

func _on_body_exit_left(b):
	if b.type() == "player" and b.get_parent() == self:
		b.current_side = null
		b.last_side = "left"
		print("EXIT LEFT")
		if b.is_connected("player_finished_move", self, "_on_player_finished_moving"):
			b.disconnect("player_finished_move", self, "_on_player_finished_moving")
		if b.is_connected("before_player_finished_move", self, "_before_player_finished_moving"):
			b.disconnect("before_player_finished_move", self, "_before_player_finished_moving")

func _on_body_enter_right(b):
	if b.type() == "player" and (b.get_parent().type() != "platform" or not b.current_side):
		b.current_side = "right"
		print("ENTERO RIGHT")
		if get_child_count() >= 7:
			b.connect("before_player_finished_move", self, "_before_player_finished_moving", [], CONNECT_ONESHOT)
			b.connect("player_finished_move", self, "_on_player_finished_moving", [], CONNECT_ONESHOT)

func _on_body_exit_right(b):
	if b.type() == "player" and b.get_parent() == self:
		b.current_side = null
		b.last_side = "right"
		print("EXIT RIGHT")
		if b.is_connected("player_finished_move", self, "_on_player_finished_moving"):
			b.disconnect("player_finished_move", self, "_on_player_finished_moving")
		if b.is_connected("before_player_finished_move", self, "_before_player_finished_moving"):
			b.disconnect("before_player_finished_move", self, "_before_player_finished_moving")

func _before_player_finished_moving(p):
	if p.current_side == "left":
		p.movement_direction = p.Order.MOVE_RIGHT
	elif p.current_side == "right":
		p.movement_direction = p.Order.MOVE_LEFT

func _on_player_finished_moving(p, tn):
	var g_pos = p.global_position
	p.get_parent().remove_child(p)
	add_child(p)
	p.rotation_degrees = 0
	p.global_position = g_pos

func _on_platform_rotation_end(obj, key):
	tween.stop_all()
	orientation = _degrees_to_orientation(rotation_degrees)

func _on_level_end_turn():
	if get_child_count() != 7:
		var g = get_node("/root/Game")
		tween.interpolate_property(self, "rotation_degrees", rotation_degrees, rotation_degrees + g.turn_rotation, ROTATION_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.start()

func _process(delta):
	if not Engine.editor_hint and not tween.is_active():
		rotation_degrees = _orientation_to_degrees(orientation)
	elif Engine.editor_hint:
		rotation_degrees = _orientation_to_degrees(orientation)