extends TileMap

func _ready():
	pass

func pos_has_tile(pos):
	var tile_pos = world_to_map(pos / 2)
	var t = get_cellv(tile_pos)
	printt(tile_pos, t)
	return t != -1