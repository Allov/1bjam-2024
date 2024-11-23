extends Node

@export var spawn_positions: Array[Vector2]
@export var current_wave = 0
@export var bugs: Array[PackedScene]
@onready var timer: Timer = $Timer


func _ready() -> void:
	timer.timeout.connect(_on_timeout)
	_on_timeout()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_timeout():
	current_wave += 1
	for i in range(current_wave):
		for bug in bugs:
			var bug_instance = bug.instantiate() as Bug
			var positions = spawn_positions.duplicate()
			positions.shuffle()
			add_child(bug_instance)
			
			var variation = Vector2(randi_range(0, 15), 0)
			
			bug_instance.global_position = positions.pop_front() + variation
			bug_instance.target = Vector2(320, 300)
