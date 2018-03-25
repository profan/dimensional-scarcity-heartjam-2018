extends Node

signal on_level_start
signal on_level_reset
signal on_level_step_start
signal on_level_step_end
signal on_level_end

signal on_player_selected(p)
signal on_player_deselected(p)
signal on_player_given_order(o)

var turn_number
var turn_rotation
var platforms = {}
var players = {}
var cur_map

func _ready():
	pass

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

func _on_player_finished_move(p, tn):
	var rotation_delta = p.rotation_delta()
	turn_rotation += rotation_delta * 90
	call_deferred("_end_turn_if_done", tn)

func _on_platform_finished_move(p, tn):
	platforms[p.name] = true

func switch_players():
	var one_selected = false
	for pid in players:
		var p = players[pid]
		if p.is_selected:
			p._on_deselect()
		elif not one_selected:
			p._on_select()
			one_selected = true

func set_map(t):
	cur_map = t

func get_map():
	return cur_map

func select_player(p):
	emit_signal("on_player_selected", p)

func start_level():
	turn_number = 1
	turn_rotation = 0

func reset_level():
	emit_signal("on_level_reset")
	platforms = {}
	players = {}

func step_level():
	emit_signal("on_level_step_start")