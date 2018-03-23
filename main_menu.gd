extends Control

onready var start_btn = get_node("buttons/start_btn")
onready var options_btn = get_node("buttons/options_btn")
onready var quit_btn = get_node("buttons/quit_btn")

func _ready():
	start_btn.connect("pressed", self, "_on_start")
	options_btn.connect("pressed", self, "_on_options")
	quit_btn.connect("pressed", self, "_on_quit")

func _on_start():
	SceneSwitcher.goto_scene("res://game.tscn")

func _on_options():
	pass

func _on_quit():
	get_tree().quit()
