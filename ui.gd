extends Control

onready var end_turn_btn = get_node("top_panel/things/end_turn_btn")

func _ready():
	end_turn_btn.connect("pressed", self, "_on_end_turn_press")

func _on_end_turn_press():
	Game.step_level()