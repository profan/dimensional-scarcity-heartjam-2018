extends TileMap

func _ready():
	pass

func pos_has_tile(pos):
	var tile_pos = world_to_map(pos)
	var t = get_cellv(tile_pos)
	printt(tile_pos, t, pos)
	return t != -1

func type():
	return "tilemap"