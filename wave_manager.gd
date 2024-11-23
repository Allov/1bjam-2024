class_name WaveManager
extends Node

signal wave_ready
signal wave_starting
signal wave_finished

@export var spawn_positions: Array[Vector2]
@export var current_wave = 0
@export var bugs: Array[PackedScene]
@onready var timer: Timer = $Timer

var wave_bug_count = 0

func _ready() -> void:
	timer.timeout.connect(_on_timeout)
	#_on_timeout()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_timeout():
	wave_ready.emit()
	
func start_wave():
	wave_starting.emit()
	current_wave += 1
	for i in range(current_wave):
		for bug in bugs:
			var bug_instance = bug.instantiate() as Bug
			bug_instance.dead.connect(_on_bug_dead)
			wave_bug_count += 1
			var positions = spawn_positions.duplicate()
			positions.shuffle()
			add_child(bug_instance)
			
			var variation = Vector2(randi_range(0, 15), 0)
			
			bug_instance.global_position = positions.pop_front() + variation
			bug_instance.target = Vector2(320, 300)

func _on_bug_dead():
	wave_bug_count -= 1
	if wave_bug_count == 0:
		wave_finished.emit()
