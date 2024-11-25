class_name Drill
extends Node2D

signal home_reached

@export var disabled = true
@export var speed = 10.0
@export var returning_speed = 125.0
@export var single_tap_time_threshold = .1
@export var underground_map: UndergroundMap
@export var mining_power = 10
@export var mining_cooldown_time = .2
@export var flying_drone_scene: PackedScene

@onready var drill_bore: CharacterBody2D = $DrillBore
@onready var drill_shaft: Line2D = $DrillShaft
@onready var left_ray: RayCast2D = $DrillBore/LeftRay
@onready var right_ray: RayCast2D = $DrillBore/RightRay
@onready var mining_particles: GPUParticles2D = $DrillBore/MiningParticles
@onready var drill_bore_sprite: AnimatedSprite2D = $DrillBore/DrillBoreSprite
@onready var drill_start: AudioStreamPlayer2D = $DrillBore/DrillStart
@onready var drill_loop: AudioStreamPlayer2D = $DrillBore/DrillLoop
@onready var drill_end: AudioStreamPlayer2D = $DrillBore/DrillEnd

var direction = 1
var charge_timer = 0.0
var charging = false
var returning_home = false
var mining_cooldown_timer = 0.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if disabled:
		return
	
	if charging:
		charge_timer += delta
	
	drill_shaft.clear_points()
	drill_shaft.add_point(drill_shaft.to_local(global_position))
	
	var moving_speed = speed

	if charging and charge_timer > single_tap_time_threshold:
		moving_speed *= 5.0
		
	if returning_home:
		moving_speed = returning_speed
	
	drill_bore.velocity.y = moving_speed * direction
	
	drill_bore.move_and_slide()

	drill_loop.pitch_scale = abs(drill_bore.velocity.y / speed) * .05 + (1.0 - .05)
	
	if drill_bore.velocity.y == 0:
		drill_loop.pitch_scale = .5

	if drill_bore.velocity.y != 0:
		play_mining_sound()
	
	if drill_bore.position.y < 0 and returning_home:
		returning_home = false
		disabled = true
		direction = 1
		home_reached.emit()
		stop_mining_sound()
		drill_bore.position.y = 0
	
	drill_shaft.add_point(drill_shaft.to_local(drill_bore.global_position))

	if charging and charge_timer > single_tap_time_threshold:
		mine(mining_power)
		
	mining_cooldown_timer -= delta

func mine(power):
	if mining_cooldown_timer > 0.0:
		return
		
	mining_cooldown_timer = mining_cooldown_time
	for ray in [left_ray, right_ray]:
		if ray.is_colliding():
			var collision_position = ray.get_collision_point()
			underground_map.mine_at(collision_position, power)
			mining_particles.emitting = true
			mining_particles.one_shot = true
			drill_bore_sprite.play("default", power / mining_power)
			
func play_mining_sound():
	if drill_start.playing or drill_loop.playing:
		return
	
	drill_start.play()
	await drill_start.finished
	drill_loop.play()
	
func stop_mining_sound():
	drill_start.stop()
	drill_loop.stop()
	drill_end.play()

func _input(event: InputEvent) -> void:
	if returning_home or disabled:
		return
	
	if event.is_action_pressed("ui_accept") and direction > 0:
		charge_timer = 0.0
		charging = true
	
	if event.is_action_released("ui_accept") and (charge_timer < single_tap_time_threshold and charging):
		charge_timer = 0.0
		charging = false
		var drone: Drone = flying_drone_scene.instantiate()
		drone.underground_map = underground_map
		var spawn_position = drill_bore.global_position + Vector2.UP * 32
		drone.target = underground_map.request_mining_target(spawn_position)
		drone.global_position = spawn_position
		get_tree().root.add_child(drone)
		
		#mine(mining_power)
		#stop_mining_sound()
	elif event.is_action_released("ui_accept"):
		charge_timer = 0.0
		charging = false
		stop_mining_sound()
		#direction *= -1

func return_home():
	stop_mining_sound()
	direction = -1
	returning_home = true
