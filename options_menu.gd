extends Control

onready var fade_checkbtn = get_node("options/fade_cont/fade_checkbtn")
onready var back_btn = get_node("back_btn")

var from_scene_name = false

func _ready():
	back_btn.connect("pressed", self, "_on_back_press")
	fade_checkbtn.connect("toggled", self, "_on_fade_checkbtn_toggle")
	fade_checkbtn.pressed = Game.use_fades

func _on_fade_checkbtn_toggle(state):
	Game.use_fades = state
	
func _input(event):
	if event is InputEventKey:
		if event.is_action("ui_cancel"):
			_on_back_press()

func _on_back_press():
	SceneSwitcher.goto_scene(from_scene_name)