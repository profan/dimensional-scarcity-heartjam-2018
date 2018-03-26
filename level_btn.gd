extends Button

func _ready():
	pass

func _pressed():
	var scene_name = "res://levels/%s.tscn" % name
	SceneSwitcher.goto_scene(scene_name)
