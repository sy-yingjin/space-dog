extends Node

var score: int = 0

func _ready() -> void:
	# ensure a ScoreLabel exists (optional)
	if has_node("ScoreLabel"):
		_update_score_label()

func add_score(points: int) -> void:
	score += points
	_update_score_label()

func _update_score_label() -> void:
	if has_node("ScoreLabel"):
		var lbl = get_node("ScoreLabel")
		lbl.text = "Score: %d" % score

func show_game_over() -> void:
	# simple game over overlay
	if has_node("GameOverOverlay"):
		return
	# Use a CanvasLayer + Control overlay so anchors work even when the scene root is Node2D
	var layer = CanvasLayer.new()
	layer.name = "GameOverOverlay"
	layer.layer = 100  # put on top
	# We avoid using SceneTree pause/pause_mode enums (they can vary between engines).
	# Instead freeze global time so gameplay halts while UI remains interactive.
	# Fullscreen ColorRect inside a Control to darken the screen
	var ctrl = Control.new()
	# no pause_mode assignment; we use Engine.time_scale below
	ctrl.anchor_left = 0.0
	ctrl.anchor_top = 0.0
	ctrl.anchor_right = 1.0
	ctrl.anchor_bottom = 1.0
	# margins not required; anchors already make this fullscreen
	var color = ColorRect.new()
	color.color = Color(0, 0, 0, 0.7)
	color.anchor_left = 0.0
	color.anchor_top = 0.0
	color.anchor_right = 1.0
	color.anchor_bottom = 1.0
	# margins not required; anchors already make this fullscreen
	ctrl.add_child(color)
	# Create a centered VBox with label + retry button
	var center = CenterContainer.new()
	# no pause_mode assignment; we use Engine.time_scale below
	center.anchor_left = 0.0
	center.anchor_top = 0.0
	center.anchor_right = 1.0
	center.anchor_bottom = 1.0
	# margins not required on CenterContainer
	var box = VBoxContainer.new()
	# Responsive sizing: cap width and scale font/button by viewport
	var vp_rect = get_viewport().get_visible_rect()
	var vp_w = vp_rect.size.x
	# cap box width at 60% of viewport or 480px max
	var max_width = min(vp_w * 0.6, 480)
	box.custom_minimum_size = Vector2(max_width, 0)
	var lbl = Label.new()
	lbl.text = "GAME OVER"
	# compute font size: base 48 at 800px width, scale down proportionally but keep min 20
	var font_size = int(clamp(48 * (vp_w / 800.0), 20, 48))
	if lbl.has_method("add_theme_font_size_override"):
		lbl.add_theme_font_size_override("font_size", font_size)
	var btn = Button.new()
	btn.text = "Retry"
	btn.name = "RetryButton"
	btn.pressed.connect(Callable(self, "_on_retry_pressed"))
	# no pause_mode assignment on button
	# button size proportional to viewport width
	var btn_w = int(clamp(vp_w * 0.2, 100, 220))
	var btn_h = int(clamp(vp_w * 0.06, 32, 60))
	btn.custom_minimum_size = Vector2(btn_w, btn_h)
	box.add_child(lbl)
	box.add_child(btn)
	center.add_child(box)
	ctrl.add_child(center)
	layer.add_child(ctrl)
	add_child(layer)
	# Freeze game time so gameplay stops but UI still receives input
	Engine.time_scale = 0.0

func _on_retry_pressed() -> void:
	# Restore global time so the engine runs normally again
	Engine.time_scale = 1.0
	# reset score and UI (optional: game scene may reset its own state)
	score = 0
	_update_score_label()
	if has_node("GameOverOverlay"):
		get_node("GameOverOverlay").queue_free()
	# use explicit scene path for reliable restart
	get_tree().change_scene_to_file("res://scenes/game.tscn")
