class_name Bullet
extends Area2D

@export var homing_minimum_distance = 20.0
@export var life_time = 2.0

var direction: Vector2
var speed = 300.0
var damage = 10
var target = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	life_time -= delta
	if life_time <= 0.0:
		queue_free()
	
	var bugs = get_tree().get_nodes_in_group("bugs")
	var nearest_distance = 9999.0
	target = null
	for bug: Bug in bugs:
		var distance = global_position.distance_to(bug.global_position)
		if distance < nearest_distance and distance < homing_minimum_distance:
			nearest_distance = distance
			target = bug.global_position
			

	if target:
		direction = direction.move_toward((target - global_position).normalized(), .03)
		
	position = position + direction * speed * delta
	
func _on_body_entered(node: Node2D):
	var bug = node as Bug
	if bug:
		bug.hit(damage)
		queue_free()
