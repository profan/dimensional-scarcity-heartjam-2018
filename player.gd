extends KinematicBody2D

enum Order {
	MOVE_NONE,
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

func _order_to_vec(o):
	match o:
		MOVE_LEFT: return Vector2(1, 0)
		MOVE_RIGHT:	 return Vector2(-1, 0)

onready var sprite = get_node("sprite")
onready var selector = get_node("selector")
onready var coll = get_node("collision")
onready var tween = get_node("tween")

var is_selected = false
var movement_direction = Order.MOVE_NONE

var MOVE_TIME = 0.5

signal player_finished_move(p)

func _ready():
	
	set_physics_process(true)
	connect("input_event", self, "_input_event")
	Game.connect("on_player_selected", self, "_on_player_selected")
	selector.visible = false
	
	# register myself
	Game.register_player(self)
	
	# connect to turn stuff
	Game.connect("on_level_step_start", self, "_on_end_turn_start")
	tween.connect("tween_completed", self, "_on_tween_done")

func rotation_delta():
	match movement_direction:
		MOVE_LEFT: return 1
		MOVE_RIGHT: return -1
		MOVE_NONE: return 0

func _on_tween_done(obj, key):
	emit_signal("player_finished_move", self, Game.turn_number)
	movement_direction = Order.MOVE_NONE
	sprite.frame = 0
	tween.stop_all()

func _on_end_turn_start():
	if movement_direction != Order.MOVE_NONE:
		var move_delta = _order_to_vec(movement_direction) * 32 # HACK FIXME
		tween.interpolate_property(self, "position", position, position + move_delta, MOVE_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.start()

func _on_player_selected(p):
	if p == self: return
	else: _on_deselect()

func _give_order(o):
		match o:
			MOVE_NONE:
				movement_direction = Order.MOVE_NONE
				sprite.frame = 0
				scale.x = 1
			MOVE_LEFT:
				movement_direction = Order.MOVE_LEFT
				sprite.frame = 1
				scale.x = 1
			MOVE_RIGHT:
				movement_direction = Order.MOVE_RIGHT
				sprite.frame = 1
				scale.x = -1

func _input(event):
	if is_selected and not tween.is_active():
		if event is InputEventMouseButton:
			if event.is_action_pressed("mouse_left"):
				_on_deselect()
			elif event.is_action_pressed("mouse_right"):
				var delta = event.global_position - global_position
				if delta.length() < 32:
					_give_order(Order.MOVE_NONE)
				else:
					var p_or = get_parent().orientation
					if p_or == Orientation.LEFT or p_or == Orientation.RIGHT:
						if p_or == Orientation.LEFT:
							if delta.y < 0:
								_give_order(Order.MOVE_LEFT)
							elif delta.y > 0:
								_give_order(Order.MOVE_RIGHT)
						else:
							if delta.y > 0:
								_give_order(Order.MOVE_LEFT)
							elif delta.y < 0:
								_give_order(Order.MOVE_RIGHT)
					elif p_or == Orientation.UP or p_or == Orientation.DOWN:
						if p_or == Orientation.DOWN:
							if delta.x < 0:
								_give_order(Order.MOVE_LEFT)
							elif delta.x > 0:
								_give_order(Order.MOVE_RIGHT)
						else:
							if delta.x > 0:
								_give_order(Order.MOVE_LEFT)
							elif delta.x < 0:
								_give_order(Order.MOVE_RIGHT)

func _input_event(viewport, ev, shape_idx):
	if ev is InputEventMouseButton:
		if ev.is_action_pressed("mouse_left"):
			_on_select()

func _physics_process(delta):
	pass

func _on_select():
	Game.select_player(self)
	is_selected = true
	selector.visible = true

func _on_deselect():
	is_selected = false
	selector.visible = false

func _on_step_start():
	pass

func _on_step_end():
	pass

func _on_reset():
	pass