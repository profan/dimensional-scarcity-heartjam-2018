extends Node2D

onready var level_map = get_node("level_map")
onready var modulator = get_node("modulator")
onready var mod_tween = get_node("mod_tween")

var from_scene_name = false
var next_scene_name = false
var SCENE_SWITCH_TIME = 0.5

func _ready():
	
	Game.set_map(self)
	
	# init shit
	Game.start_level()
	
	modulator.color.a = 0
	mod_tween.connect("tween_completed", self, "_on_mod_tween_load_end")
	mod_tween.interpolate_property(modulator, "color", Color(1, 1, 1, 0), Color(1, 1, 1, 1), SCENE_SWITCH_TIME, Tween.TRANS_CUBIC, Tween.EASE_IN)
	mod_tween.start()

func _on_mod_tween_load_end():
	mod_tween.connect("tween_completed", self, "_on_mod_tween_end_level")

func _on_mod_tween_end_level():
	SceneSwitcher.goto_scene(next_scene_name)
	
func end_level():
	mod_tween.interpolate_property(modulator, "color", Color(1, 1, 1, 1), Color(1, 1, 1, 0), SCENE_SWITCH_TIME, Tween.TRANS_CUBIC, Tween.EASE_IN)
	mod_tween.start()

func on_load_level():
	pass

func pos_has_tile(pos):
	return level_map.pos_has_tile(pos)
	
func pos_has_tile_local(pos):
	return level_map.pos_has_tile(pos)

func reparent_child(n):
	level_map.add_child(n)

func type():
	return "map"
