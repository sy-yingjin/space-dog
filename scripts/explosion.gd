extends Node2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

signal finished()

func _ready() -> void:
    # connect animation finished to queue_free
    if anim != null:
        anim.animation_finished.connect(_on_anim_finished)

func _on_anim_finished() -> void:
    emit_signal("finished")
    queue_free()
