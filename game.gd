extends Node

signal on_level_start
signal on_level_reset
signal on_level_step_start
signal on_level_step_end
signal on_level_step_end_rot
signal on_level_end

signal on_player_selected(p)
signal on_player_deselected(p)
signal on_player_given_order(o)

onready var plat_timer = get_node("platform_timer")

# global config
var use_fades = true

# game vars

var is_rotating

var turn_number
var turn_rotation
var players_done
var platforms = {}
var players = {}
var cur_map

func _ready():
	plat_timer.wait_time = 0.2 # HACK HARDCODED FIXME
	plat_timer.connect("timeout", self, "_on_plat_rotation_done")

func _on_plat_rotation_done():
	emit_signal("on_level_step_end_rot")
	plat_timer.stop()

# register things
func register_player(p):
	players[p.name] = p
	p.connect("player_finished_move", self, "_on_player_finished_move")

func register_platform(p):
	platforms[p.name] = p
	# p.connect("platform_finished_move", self, "_on_platform_finished_move")

# game loop shit

func _end_turn_if_done(tn):
	
	var players_done = 0
	for p in players:
		if players[p]:
			players_done += 1
	
	if players_done == players.size() and tn == turn_number:
		emit_signal("on_level_step_end")
		turn_rotation = 0
		turn_number += 1
		plat_timer.start()

func _on_player_finished_move(p, tn):
	var rotation_delta = p.rotation_delta()
	turn_rotation += rotation_delta * 90
	call_deferred("_end_turn_if_done", tn)

func _on_platform_finished_move(p, tn):
	platforms[p.name] = true

func player_reached_goal(p):
	players_done += 1
	if players_done == players.size():
		emit_signal("on_level_end")

var last_selected
func switch_players():
	var one_selected = false
	var one_deselected = false
	
	if players.size() == 2:
		for pid in players:
			var p = players[pid]
			if p.is_selected:
				p._on_deselect()
				one_deselected = true
			elif (not one_selected and not p.has_reached_goal):
				p._on_select()
				one_selected = true
	elif players.size() > 2:
		for pid in players:
			var p = players[pid]
			if p.is_selected:
				p._on_deselect()
				last_selected = p
				one_deselected = true
			elif (not one_selected and not p.has_reached_goal) and not last_selected == p:
				p._on_select()
				one_selected = true
				
		if not one_selected and not one_deselected:
			if last_selected.is_selected:
				last_selected._on_deselect()
			else:
				last_selected._on_select()

func set_map(t):
	cur_map = t

func get_map():
	return cur_map

func select_player(p):
	emit_signal("on_player_selected", p)

func start_level():
	turn_number = 1
	turn_rotation = 0
	players_done = 0

func reset_level():
	emit_signal("on_level_reset")
	last_selected = null
	players_done = 0
	platforms = {}
	players = {}

func step_level():
	emit_signal("on_level_step_start")