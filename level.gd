extends Node2D

export(String) var next_level
export(String) var level_title

onready var level_map = get_node("level_map")
onready var modulator = get_node("modulator")
onready var ui_modulator = get_node("canvas/ui_mod")
onready var mod_tween = get_node("mod_tween")
onready var level_title_label = get_node("canvas/level_title")

var from_scene_name = false
var next_scene_name = false
var SCENE_SWITCH_TIME = 0.5

var tweens_done = 0

func _ready():
	
	Game.connect("on_level_end", self, "_on_end_level")
	
	Game.set_map(self)
	
	# init shit
	Game.start_level()
	
	modulator.color.a = 0
	level_title_label.modulate.a = 0
	mod_tween.connect("tween_completed", self, "_on_mod_tween_load_end")
	mod_tween.interpolate_property(modulator, "color", Color(1, 1, 1, 0), Color(1, 1, 1, 1), SCENE_SWITCH_TIME, Tween.TRANS_CUBIC, Tween.EASE_IN)
	mod_tween.interpolate_property(ui_modulator, "color", Color(1, 1, 1, 0), Color(1, 1, 1, 1), SCENE_SWITCH_TIME, Tween.TRANS_CUBIC, Tween.EASE_IN)
	mod_tween.start()
	
	if level_title: level_title_label.text = level_title
	
	if next_level: next_scene_name = "res://levels/%s.tscn" % next_level

func _on_mod_tween_load_end(obj, key):
	tweens_done += 1;
	if tweens_done == 2:
		mod_tween.disconnect("tween_completed", self, "_on_mod_tween_load_end")
		mod_tween.interpolate_property(level_title_label, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), SCENE_SWITCH_TIME * 2, Tween.TRANS_CUBIC,Tween.EASE_IN)
		mod_tween.connect("tween_completed", self, "_on_mod_tween_fade_title_in", [], CONNECT_ONESHOT)
		mod_tween.start()

func _on_mod_tween_fade_title_in(obj, key):
	print("YAH")
	mod_tween.interpolate_property(level_title_label, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), SCENE_SWITCH_TIME * 2, Tween.TRANS_CUBIC,Tween.EASE_IN)
	mod_tween.connect("tween_completed", self, "_on_mod_tween_fade_title_out", [], CONNECT_ONESHOT)
	mod_tween.start()

func _on_mod_tween_fade_title_out(obj, key):
	level_title_label.visible = false

func _on_mod_tween_end_level(obj, key):
	
	Game.reset_level()
	
	if next_scene_name:
		SceneSwitcher.goto_scene(next_scene_name)
	else:
		SceneSwitcher.goto_scene("res://main_menu.tscn")
	
func _on_end_level():
	mod_tween.connect("tween_completed", self, "_on_mod_tween_end_level")
	mod_tween.interpolate_property(modulator, "color", Color(1, 1, 1, 1), Color(1, 1, 1, 0), SCENE_SWITCH_TIME, Tween.TRANS_CUBIC, Tween.EASE_IN)
	mod_tween.interpolate_property(ui_modulator, "color", Color(1, 1, 1, 1), Color(1, 1, 1, 0), SCENE_SWITCH_TIME, Tween.TRANS_CUBIC, Tween.EASE_IN)
	mod_tween.start()

func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("reset_level"):
			Game.reset_level()
			reload_level()

func reload_level():
	SceneSwitcher.goto_scene(filename)

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
