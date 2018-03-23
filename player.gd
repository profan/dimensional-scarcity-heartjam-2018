extends KinematicBody2D

enum Orientation {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

export (Orientation) var orientation = Orientation.UP;

func _orientation_to_degrees(o):
	match o:
		UP: return 0
		DOWN: return 180
		LEFT: return -90
		RIGHT: return 90

func _orientation_to_upvec(o):
	match o:
		UP: return Vector2(0, -1)
		DOWN: return Vector2(0, 1)
		LEFT: return Vector2(-1, 0)
		RIGHT: return Vector2(1, 0)

func _ready():
	set_physics_process(true)

func _physics_process(delta):
	pass

func _on_step():
	pass

func _on_reset():
	pass