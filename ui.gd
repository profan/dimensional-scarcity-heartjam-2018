extends Control

onready var turn_label = get_node("top_panel/things/turn_label")
onready var end_turn_btn = get_node("top_panel/things/end_turn_btn")

func _ready():
	end_turn_btn.connect("pressed", self, "_on_end_turn_press")
	Game.connect("on_level_step_end", self, "_on_turn_end")

func _on_turn_end():
	turn_label.text = "Turn Number: %d" % Game.turn_number

func _on_end_turn_press():
	Game.step_level()