extends Area2D

func _ready():
	connect("body_entered", self, "_on_body_enter")

func _on_body_enter(b):
	if b.type() == "player" and not b.has_reached_goal:
		b.reached_goal()