extends ParallaxBackground

@onready var Space: ParallaxLayer = $SpaceLayer
@onready var WStars: ParallaxLayer = $WStarsLayer
@onready var BYStars: ParallaxLayer = $BYStarsLayer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	WStars.motion_offset.y += 10 * delta
	BYStars.motion_offset.y += 30 * delta
	pass
