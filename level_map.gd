extends TileMap

func _ready():
	pass

func pos_has_tile(pos):
	var t = get_cellv(pos / 2)
	return t != -1