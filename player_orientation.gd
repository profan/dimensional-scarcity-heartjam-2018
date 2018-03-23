extends Sprite
tool

func _ready():
	if Engine.editor_hint:
		set_process(true)
	else:
		set_process(false)

enum Orientation {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

func orientation_to_degrees(o):
	match o:
		UP: return 0
		DOWN: return 180
		LEFT: return -90
		RIGHT: return 90

func _process(delta):
	var parent = get_parent()
	rotation_degrees = orientation_to_degrees(parent.orientation)