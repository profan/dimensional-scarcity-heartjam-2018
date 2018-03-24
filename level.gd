extends Node2D

onready var level_map = get_node("level_map")

func _ready():
	
	Game.set_map(self)
	
	# init shit
	Game.start_level()

func pos_has_tile(pos):
	return level_map.pos_has_tile(pos)
	
func pos_has_tile_local(pos):
	return level_map.pos_has_tile(pos)

func reparent_child(n):
	level_map.add_child(n)

func type():
	return "map"
