extends Node

var turn_number

signal on_level_start
signal on_level_step
signal on_level_reset
signal on_level_end

signal on_player_selected(p)
signal on_player_deselected(p)
signal on_player_given_order(o)

func _ready():
	pass

func select_player(p):
	emit_signal("on_player_selected", p)

func start_level():
	turn_number = 0

func reset_level():
	pass

func step_level():
	pass