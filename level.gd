extends Node2D

func _ready():
	
	Game.set_map(self)
	
	# init shit
	Game.start_level()
