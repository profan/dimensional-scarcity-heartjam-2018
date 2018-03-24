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
onready var timer = get_node("timer")

# what side am i on currently
var current_side
var last_side

var is_selected = false
var movement_direction = Order.MOVE_NONE
var do_crouch = false

var MOVE_TIME = 0.5
var map

signal player_finished_move(p)

# debug
var debug_pos_above
var debug_pos

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
	timer.connect("timeout", self, "_on_end_timer_done")
	
	call_deferred("_after_ready")

func _after_ready():
	map = Game.get_map()

func rotation_delta():
	match movement_direction:
		MOVE_LEFT: return 1
		MOVE_RIGHT: return -1
		MOVE_NONE: return 0

func set_tilemap(t):
	map = t

func type():
	return "player"

func _on_tween_done(obj, key):
	
	if last_side == "left" and movement_direction == Order.MOVE_LEFT:
		movement_direction = Order.MOVE_NONE
		last_side = null
	elif last_side == "right" and movement_direction == Order.MOVE_RIGHT:
		movement_direction = Order.MOVE_NONE
		last_side = null
		
	# moving off platform
	elif last_side == "right" and movement_direction == Order.MOVE_LEFT:
		movement_direction = Order.MOVE_NONE
		
		var parent = get_parent()
		if parent.type() == "platform":
			var g_pos = global_position
			orientation = parent.orientation
			rotation_degrees = parent.rotation_degrees
			parent.remove_child(self)
			map.reparent_child(self)
			self.global_position = g_pos
		
	elif last_side == "left" and movement_direction == Order.MOVE_RIGHT:
		movement_direction = Order.MOVE_NONE
		
		var parent = get_parent()
		if parent.type() == "platform":
			var g_pos = global_position
			orientation = parent.orientation
			rotation_degrees = parent.rotation_degrees
			parent.remove_child(self)
			map.reparent_child(self)
			self.global_position = g_pos
	
	if get_parent().type() != "platform":
		movement_direction = Order.MOVE_NONE
	
	emit_signal("player_finished_move", self, Game.turn_number)
	movement_direction = Order.MOVE_NONE
	tween.stop_all()

func do_crouch():
	sprite.frame = 2
	timer.wait_time = 0.5
	timer.start()

func _on_end_timer_done():
	sprite.frame = 0
	timer.stop()

func _on_end_turn_start():
	if movement_direction != Order.MOVE_NONE:
		var move_delta = _order_to_vec(movement_direction) * 32 # HACK FIXME
		tween.interpolate_property(self, "position", position, position + move_delta, MOVE_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN)
		sprite.frame = 0
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
				if get_parent().type() == "platform":
					if current_side != "right":
						movement_direction = Order.MOVE_LEFT
						sprite.frame = 1
						scale.x = 1
					else:
						print("RIGHTO?")
						scale.x = 1
						sprite.frame = 0
						movement_direction = Order.MOVE_NONE
						var right_above_pos = position + Vector2(16, 0)
						var right_pos = position + Vector2(16, 64)
						var g_above_pos = to_global(right_above_pos)
						var g_pos = to_global(right_pos)
						debug_pos_above = g_above_pos
						debug_pos = g_pos
						update()
						# reparent to tilemap or new platform
						if not map.pos_has_tile(g_above_pos) and map.pos_has_tile(g_pos):
							print("MOVAN RIGHTAN")
							movement_direction = Order.MOVE_LEFT
							sprite.frame = 1
				else:
					print("TILE RIGHTO")
					var right_above_pos = position + Vector2(16, 0)
					var right_pos = position + Vector2(16, 64)
					var g_above_pos = to_global(right_above_pos)
					var g_pos = to_global(right_pos)
					if not map.pos_has_tile_local(g_above_pos) and map.pos_has_tile_local(g_pos):
						print("MOVAN TILE RIGHTO")
						movement_direction = Order.MOVE_LEFT
						sprite.frame = 1
						scale.x = 1
			MOVE_RIGHT:
				if get_parent().type() == "platform":
					if current_side != "left":
						movement_direction = Order.MOVE_RIGHT
						sprite.frame = 1
						scale.x = -1
					else:
						print("LEFTO?")
						scale.x = -1
						sprite.frame = 0
						movement_direction = Order.MOVE_NONE
						var left_above_pos = position + Vector2(64, 16)
						var left_pos = position + Vector2(64, 48)
						var g_above_pos = to_global(left_above_pos)
						var g_pos = to_global(left_pos)
						debug_pos_above = g_above_pos
						debug_pos = g_pos
						update()
						# reparent to tilemap or new platform
						if not map.pos_has_tile(g_above_pos) and map.pos_has_tile(g_pos):
							print("MOVAN LEFTAN")
							movement_direction = Order.MOVE_RIGHT
							sprite.frame = 1
				else:
					print("TILE LEFTO")
					var left_above_pos = position
					var left_pos = position + Vector2(64, 48)
					var g_above_pos = to_global(left_above_pos)
					var g_pos = to_global(left_pos)
					if not map.pos_has_tile_local(g_above_pos) and map.pos_has_tile_local(g_pos):
						print("MOVAN TILE LEFTO")
						movement_direction = Order.MOVE_RIGHT
						sprite.frame = 1
						scale.x = -1

func _draw():
	if debug_pos_above and debug_pos:
		# var inv = get_global_transform().inverse()
		#draw_set_transform(inv.get_origin(), inv.get_rotation(), inv.get_scale())
		draw_rect(Rect2(16, -16, 32, 32), ColorN("fuchsia"))
		draw_rect(Rect2(16, 16, 32, 32), ColorN("green"))

func _input(event):
	
	if event is InputEventMouseButton:
		if event.is_action_pressed("mouse_left"):
			print("tile has pos: %s" % [map.pos_has_tile(event.global_position)])
			
	if is_selected and not tween.is_active():
		if event is InputEventMouseButton:
			if event.is_action_pressed("mouse_left"):
				_on_deselect()
			elif event.is_action_pressed("mouse_right"):
				var delta = event.global_position - global_position
				if delta.length() < 32:
					_give_order(Order.MOVE_NONE)
				else:
					
					var p_or
					if get_parent().type() == "platform":
						p_or = get_parent().orientation
					else:
						p_or = orientation
						
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