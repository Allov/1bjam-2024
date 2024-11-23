extends Node2D

@onready var animation_player: AnimationPlayer = $UI/AnimationPlayer

func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		animation_player.play("start")

func _on_animation_finished(animation: String):
	if animation == "start":
		get_tree().change_scene_to_file("res://world.tscn")
