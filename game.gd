extends Node

var turn_number

signal on_level_start
signal on_level_reset
signal on_level_end

func _ready():
	pass

func start_level():
	turn_number = 0

func reset_level():
	pass