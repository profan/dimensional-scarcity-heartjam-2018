extends Node

var current_scene

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	
func goto_scene(path, args=[]):
	call_deferred("_deferred_goto_scene", path, args)

func _deferred_goto_scene(path, args=[]):
	
	# Store old name so we can pass it to next one
	var current_scene_name = current_scene.get_filename()

	# Immediately free the current scene,
	# there is no risk here.
	current_scene.free()

	# Load new scene
	var s = ResourceLoader.load(path)

	# Instance the new scene
	current_scene = s.instance()
	
	if "from_scene_name" in current_scene:
		current_scene.from_scene_name = current_scene_name

	# Add it to the active scene, as child of root
	get_tree().get_root().add_child(current_scene)
	# optional, to make it compatible with the SceneTree.change_scene() API
	get_tree().set_current_scene(current_scene)
