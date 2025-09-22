class_name SpawnBullet
extends Node2D

# Export the dependencies for this component
# The scene we want to spawn
@export var scene: PackedScene

# Spawn an instance of the scene at a specific global position on a parent
# By default the parent is the current "main" scene , but you can pass in
# an alternative parent if you so choose.
func spawn(global_spawn_position: Vector2 = global_position, parent: Node = get_tree().current_scene) -> Node:
	assert(scene is PackedScene, "Error: the scene export was never set on this spawner component.")
	
	# instance the scene / "spawn" object
	var instance = scene.instantiate()
	
	# add it as a child of the parent
	parent.add_child(instance)
	
	# update the global position of instance after
	# setting it as a child of the parent
	instance.global_position = global_spawn_position
	
	# return in case we want to perform other operations
	return instance
