extends KinematicBody2D

enum Order {
	MOVE_LEFT,
	MOVE_RIGHT
}

enum Orientation {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

export (Orientation) var orientation = Orientation.UP;

func _orientation_to_degrees(o):
	match o:
		UP: return 0
		DOWN: return 180
		LEFT: return -90
		RIGHT: return 90

func _orientation_to_upvec(o):
	match o:
		UP: return Vector2(0, -1)
		DOWN: return Vector2(0, 1)
		LEFT: return Vector2(-1, 0)
		RIGHT: return Vector2(1, 0)

onready var sprite = get_node("sprite")
onready var coll = get_node("collision")
onready var arrow = get_node("arrow")

var is_selected = false
var movement_direction

func _ready():
	set_physics_process(true)
	connect("input_event", self, "_input_event")
	Game.connect("on_player_selected", self, "_on_player_selected")

func _on_player_selected(p):
	if p == self: return
	else: _on_deselect()

func _on_player_given_order(o):
	if is_selected:
		match o:
			MOVE_LEFT:
				movement_direction = Order.MOVE_LEFT
				arrow.visible = true
				rotation_degrees = 180
			MOVE_RIGHT:
				movement_direction = Order.MOVE_RIGHT
				arrow.visible = true
				rotation_degrees = 0

func _input_event(viewport, ev, shape_idx):
	if ev is InputEventMouseButton:
		_on_select()
		if ev.is_action_pressed("ui_left"):
			_on_select()

func _physics_process(delta):
	pass

func _on_select():
	Game.select_player(self)
	is_selected = true
	sprite.frame = 1

func _on_deselect():
	is_selected = false
	sprite.frame = 0

func _on_step_start():
	pass

func _on_step_end():
	pass

func _on_reset():
	pass