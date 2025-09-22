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
