extends Control

onready var start_btn = get_node("buttons/start_btn")
onready var options_btn = get_node("buttons/options_btn")
onready var how_btn = get_node("buttons/how_btn")
onready var quit_btn = get_node("buttons/quit_btn")

func _ready():
	start_btn.connect("pressed", self, "_on_start")
	options_btn.connect("pressed", self, "_on_options")
	how_btn.connect("pressed", self, "_on_how")
	quit_btn.connect("pressed", self, "_on_quit")

func _on_start():
	SceneSwitcher.goto_scene("res://levels/level_1.tscn")

func _on_options():
	SceneSwitcher.goto_scene("res://options_menu.tscn")

func _on_how():
	SceneSwitcher.goto_scene("res://how_to_play.tscn")

func _on_quit():
	get_tree().quit()
