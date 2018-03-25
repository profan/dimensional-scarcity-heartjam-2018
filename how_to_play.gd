extends Control

onready var back_btn = get_node("back_btn")

var from_scene_name

func _ready():
	back_btn.connect("pressed", self, "_on_back_press")

func _input(event):
	if event is InputEventKey:
		if event.is_action("ui_cancel"):
			_on_back_press()

func _on_back_press():
	SceneSwitcher.goto_scene(from_scene_name)