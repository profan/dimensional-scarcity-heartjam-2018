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
var players = {}

func _ready():
	pass

# register things
func register_player(p):
	players[p.name] = p
	p.connect("player_finished_move", self, "_on_player_finished_move")

# game loop shit

func _end_turn_if_done():
	
	var players_done = 0
	for p in players:
		if players[p]:
			players_done += 1
	
	if players_done == players.size():
		emit_signal("on_level_step_end")
		turn_number += 1

func _on_player_finished_move(p):
	players[p.name] = true
	_end_turn_if_done()

func select_player(p):
	emit_signal("on_player_selected", p)

func start_level():
	turn_number = 0
	players = {}

func reset_level():
	emit_signal("on_level_reset")

func step_level():
	emit_signal("on_level_step_start")