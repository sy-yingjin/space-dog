extends Node2D

@onready var visible_on_screen_enabler_2d: VisibleOnScreenEnabler2D = $VisibleOnScreenEnabler2D

var speed = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# destroy bullet when exits screen
	visible_on_screen_enabler_2d.screen_exited.connect(queue_free)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# constant movement of bullet
	position += Vector2(0, -1) * speed * delta

	# check for collisions at this point (enemies)
	var space_state = get_world_2d().direct_space_state
	var params = PhysicsPointQueryParameters2D.new()
	params.position = position
	params.collide_with_bodies = true
	params.collide_with_areas = false
	params.exclude = []
	params.collision_mask = 0x7FFFFFFF
	var results = space_state.intersect_point(params)
	for r in results:
		var col = r.collider
		if col != null and col.is_in_group("enemies"):
			# increment score via Game node
			var root = get_tree().current_scene
			if root != null and root.has_method("add_score"):
				root.call("add_score", 100)
			# remove enemy and this bullet
			col.queue_free()
			queue_free()
			return
