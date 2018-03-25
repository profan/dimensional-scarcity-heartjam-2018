extends Control

onready var turn_label = get_node("top_panel/things/turn_label")
onready var end_turn_btn = get_node("top_panel/things/end_turn_btn")

# menu
onready var menu_panel = get_node("menu_panel")
onready var menu_reset_btn = get_node("menu_panel/things/reset_btn")
onready var menu_yes_btn = get_node("menu_panel/things/yes_btn")
onready var menu_no_btn = get_node("menu_panel/things/no_btn")

var selected_player

func _ready():
	end_turn_btn.connect("pressed", self, "_on_end_turn_press")
	Game.connect("on_level_step_end", self, "_on_turn_end")
	menu_reset_btn.connect("pressed", self, "_on_menu_reset_btn")
	menu_yes_btn.connect("pressed", self, "_on_menu_yes_btn")
	menu_no_btn.connect("pressed", self, "_on_menu_no_btn")
	menu_panel.visible = false

func _on_turn_end():
	turn_label.text = "Turn: %d" % Game.turn_number

func _on_end_turn_press():
	Game.step_level()

func _on_menu_reset_btn():
	SceneSwitcher.current_scene.reload_level()

func _on_menu_yes_btn():
	SceneSwitcher.goto_scene("res://main_menu.tscn")

func _on_menu_no_btn():
	menu_panel.visible = false

func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("player_switch"):
			Game.switch_players()
		elif event.is_action_pressed("ui_cancel"):
			menu_panel.visible = !menu_panel.visible

func _unhandled_input(event):
	if event is InputEventKey:
		if event.is_action_pressed("player_end_turn"):
			_on_end_turn_press()