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
		LEFT: return Vector2(1, 0)
		RIGHT: return Vector2(-1, 0)

func _order_to_vec(o):
	match o:
		MOVE_LEFT: return Vector2(1, 0)
		MOVE_RIGHT:	 return Vector2(-1, 0)

func _order_to_vec_side(o):
	match o:
		MOVE_LEFT: return Vector2(0, 1)
		MOVE_RIGHT:	 return Vector2(0, -1)

onready var sprite = get_node("sprite")
onready var selector = get_node("selector")
onready var coll = get_node("collision")
onready var tween = get_node("tween")
onready var timer = get_node("timer")
onready var front_area = get_node("front")

# what side am i on currently
var current_side
var last_side

var is_selected = false
var movement_direction = Order.MOVE_NONE
var do_crouch = false

var MOVE_TIME = 0.5
var map

signal before_player_finished_move(p)
signal player_finished_move(p, tn)

# controle
var has_reached_goal
var can_move

# debug
var debug_pos_above
var debug_pos

# to other platform moving
var other_platform_infront = false
var other_platform_dir = 0

func _ready():
	
	set_physics_process(true)
	connect("input_event", self, "_input_event")
	Game.connect("on_player_selected", self, "_on_player_selected")
	selector.visible = false
	
	# register myself
	Game.register_player(self)
	
	# connect to turn stuff
	Game.connect("on_level_step_start", self, "_on_end_turn_start")
	Game.connect("on_level_step_end_rot", self, "_on_step_rot_end")
	tween.connect("tween_completed", self, "_on_tween_done")
	timer.connect("timeout", self, "_on_end_timer_done")
	front_area.connect("area_entered", self, "_on_front_area_entered")
	front_area.connect("area_exited", self, "_on_front_area_exited")
	
	call_deferred("_after_ready")
	can_move = true

func _on_front_area_entered(a):
	if a.get_parent().type() == "platform":
		other_platform_infront = true
		other_platform_dir = scale.x

func _on_front_area_exited(a):
	if a.get_parent().type() == "platform":
		other_platform_infront = false
		other_platform_dir = 0

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
	
	emit_signal("before_player_finished_move", self)
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
		var move_delta
		if get_parent().type() == "platform":
			move_delta = _order_to_vec(movement_direction) * 32 # HACK FIXME
		else:
			var move_vec
			match [movement_direction, orientation]:
				[MOVE_LEFT, UP], [MOVE_RIGHT, UP]: move_vec = _order_to_vec(movement_direction)
				[MOVE_LEFT, DOWN], [MOVE_RIGHT, DOWN]: 
					move_vec = _order_to_vec(movement_direction)
					move_vec.x = -move_vec.x
				[MOVE_LEFT, LEFT], [MOVE_RIGHT, LEFT]: 
					move_vec = _order_to_vec_side(movement_direction)
					move_vec.y = -move_vec.y
				[MOVE_LEFT, RIGHT], [MOVE_RIGHT, RIGHT]: move_vec = _order_to_vec_side(movement_direction)
			move_delta = move_vec * 32
		tween.interpolate_property(self, "position", position, position + move_delta, MOVE_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN)
		sprite.frame = 0
		tween.start()
		can_move = false

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
					# reparent to tilemap or new platform
					if not map.pos_has_tile(g_above_pos) and map.pos_has_tile(g_pos):
						print("MOVAN RIGHTAN")
						movement_direction = Order.MOVE_LEFT
						sprite.frame = 1
			else:
				print("TILE RIGHTO")
				scale.x = 1
				sprite.frame = 0
				movement_direction = Order.MOVE_NONE
				var right_above_pos = global_position + Vector2(64, 0).rotated(rotation)
				var right_pos = global_position + Vector2(64, 64).rotated(rotation)
				var g_above_pos = right_above_pos
				var g_pos = right_pos
				if not map.pos_has_tile_local(g_above_pos) and map.pos_has_tile_local(g_pos):
					print("MOVAN TILE RIGHTO")
					movement_direction = Order.MOVE_LEFT
					sprite.frame = 1
				elif other_platform_infront and other_platform_dir == 1:
					print("MOVAN PLATFORM RIGHTO")
					movement_direction = Order.MOVE_LEFT
					sprite.frame = 1
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
					if get_parent().orientation == Orientation.LEFT:
						left_above_pos.x -= 16
						left_pos.x -= 16
					elif get_parent().orientation == Orientation.RIGHT:
						left_above_pos.x += 16
						left_pos.x += 16
						left_above_pos.y += 16
						left_pos.y += 16
					elif get_parent().orientation == Orientation.DOWN:
						left_above_pos.y += 16
						left_pos.y += 16
					var g_above_pos = to_global(left_above_pos)
					var g_pos = to_global(left_pos)
					# reparent to tilemap or new platform
					if not map.pos_has_tile(g_above_pos) and map.pos_has_tile(g_pos):
						print("MOVAN LEFTAN")
						movement_direction = Order.MOVE_RIGHT
						sprite.frame = 1
			else:
				print("TILE LEFTO")
				sprite.frame = 0
				movement_direction = Order.MOVE_NONE
				scale.x = 1
				var left_above_pos = global_position + Vector2(-64, 16).rotated(rotation)
				var left_pos = global_position + Vector2(-64, 48).rotated(rotation)
				var g_above_pos = left_above_pos
				var g_pos = left_pos
				scale.x = -1
				if not map.pos_has_tile_local(g_above_pos) and map.pos_has_tile_local(g_pos):
					print("MOVAN TILE LEFTO")
					movement_direction = Order.MOVE_RIGHT
					sprite.frame = 1
				elif other_platform_infront  and other_platform_dir == -1:
					print("MOVAN PLATFORM LEFTO")
					movement_direction = Order.MOVE_RIGHT
					sprite.frame = 1

func _draw():
	if debug_pos_above and debug_pos:
		# var inv = get_global_transform().inverse()
		# draw_set_transform(inv.get_origin(), inv.get_rotation(), inv.get_scale())
		# draw_rect(Rect2(debug_pos.x, debug_pos.y, 16, 16), ColorN("fuchsia"))
		# draw_rect(Rect2(debug_pos_above.x, debug_pos_above.y, 16, 16), ColorN("green"))
		draw_rect(Rect2(16, -16, 32, 32), ColorN("fuchsia"))
		draw_rect(Rect2(16, 16, 32, 32), ColorN("green"))

func _input(event):
	
	if not can_move: return
	
	if event is InputEventMouseButton:
		if event.is_action_pressed("mouse_left"):
			print("tile has pos: %s" % [map.pos_has_tile(event.global_position)])
			
	if is_selected and not tween.is_active():
		if event is InputEventKey:
			if event.is_action_pressed("player_move_left"):
				_give_order(Order.MOVE_RIGHT)
			elif event.is_action_pressed("player_move_right"):
				_give_order(Order.MOVE_LEFT)
			elif event.is_action_pressed("player_move_none"):
				_give_order(Order.MOVE_NONE)
		elif event is InputEventMouseButton:
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
		if ev.is_action_pressed("mouse_left") and not has_reached_goal:
			_on_select()

func _physics_process(delta):
	pass

func reached_goal():
	has_reached_goal = true
	Game.player_reached_goal(self)

func _on_select():
	Game.select_player(self)
	is_selected = true
	selector.visible = true

func _on_deselect():
	is_selected = false
	selector.visible = false

func _on_step_rot_end():
	if not has_reached_goal:
		can_move = true

func _on_reset():
	pass