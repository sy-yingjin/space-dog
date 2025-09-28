extends CharacterBody2D

@onready var right_muzzle: Marker2D = $RightMuzzle
@onready var left_muzzle: Marker2D = $LeftMuzzle
@onready var spawn_bullet: SpawnBullet = $SpawnBullet
@onready var fire_timer: Timer = $fireTimer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var HP = 100

func _ready() -> void:
	fire_timer.timeout.connect(fire_bullets)
	add_to_group("enemies")

func _process(delta: float) -> void:
	
	
	if HP <= 0:
		animated_sprite_2d.play("destroyed")
		# update score (find Game node)
		var root = get_tree().current_scene
		if root != null and root.has_method("add_score"):
			root.call("add_score", 100)
		queue_free()
	
	pass

func fire_bullets() -> void:
	spawn_bullet.spawn(right_muzzle.global_position)
	spawn_bullet.spawn(left_muzzle.global_position)
	
