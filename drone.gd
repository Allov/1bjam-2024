class_name Drone
extends CharacterBody2D

@export var underground_map: UndergroundMap
@export var life_time = 15.0
@onready var line_2d: Line2D = $Line2D
@onready var mining_ray: RayCast2D = $MiningRay

const SPEED = 10.0

# possible states: FINDING, MINING
var state = "FINDING"
var target = null

func _physics_process(delta: float) -> void:
	
	life_time -= delta
	
	if life_time <= 0:
		queue_free()
	
	if target == null:
		target = underground_map.request_mining_target(global_position - Vector2(0, 0))
		
		if target == null:
			queue_free()
	
	var direction = Vector2.ZERO
	if target:
		line_2d.clear_points()
		line_2d.add_point(line_2d.to_local(target))
		line_2d.add_point(line_2d.to_local(global_position))
		direction = (target - global_position).normalized()
		
		mining_ray.target_position = mining_ray.position + direction * 12
	
	if mining_ray.is_colliding():
		var collision_position = mining_ray.to_global(mining_ray.target_position)
		if underground_map.mine_at(collision_position, 1.0): 
			target = null
		
	if direction:
		velocity = direction * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)

	move_and_slide()
