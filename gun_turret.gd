class_name GunTurret
extends Node2D

@export var disabled = false
@export var radius_x: float = 100.0 
@export var radius_y: float = 80.0 
@export var max_speed = 1.0
@export var acceleration = 0.8
@export var bullet_scene: PackedScene
@export var stop_time = 0.5
@export var maximum_heat = 1.0
@export var heat_per_shot = .1
@export var heat_per_second_while_charging = .1
@export var overheat_cooldown_time = 2.0
@export var charged_shot_time = 1.0
@export var single_shot_time_threshold = .1
@export var heat_loss_per_second = .2

@onready var gun_turret_sprite: Sprite2D = $GunTurretSprite
@onready var nozzle: Node2D = $GunTurretSprite/Nozzle

var angle: float = 0.0
var center: Vector2 = Vector2.ZERO
var stop_timer = 0.0
var speed: float = 0.0 
var direction = 1.0
var heat = 0.0
var overheat_cooldown_timer = 0.0
var charged_shot_timer = 0.0
var charging_shot = false

func _ready() -> void:
	speed = 0.0
	center = global_position

func _process(delta: float) -> void:
	stop_timer -= delta

	if charging_shot:
		charged_shot_timer += delta
		heat += heat_per_second_while_charging * delta
		
	if charging_shot and overheat_cooldown_timer <= 0.0:
		speed = 0
		return
		
	if overheat_cooldown_timer > 0.0:
		overheat_cooldown_timer -= delta
		
	if heat > 0.0 and overheat_cooldown_timer <= 0.0:
		heat -= heat_loss_per_second * delta
	
	speed = lerpf(speed, max_speed, acceleration * delta)

	if disabled:
		charging_shot = false
		charged_shot_timer = 0.0
		speed = 0.0

	angle += speed * direction * delta
	
	if angle > 0 or angle < -PI:
		speed = 0.0
		direction = direction * -1
		
		if angle < -PI:
			angle = -PI
		else:
			angle = 0
	
	var x = center.x + radius_x * cos(angle)
	var y = center.y + radius_y * sin(angle)
	
	gun_turret_sprite.rotation = angle + PI / 2	
	
	position = Vector2(x, y)

func _input(event: InputEvent) -> void:
	if disabled:
		return
		
	if event.is_action_pressed("ui_accept") and overheat_cooldown_timer <= 0.0 and not charging_shot:
		charging_shot = true
	
	if event.is_action_released("ui_accept") and overheat_cooldown_timer <= 0.0 and charged_shot_timer < single_shot_time_threshold and charging_shot:
		charged_shot_timer = 0.0
		charging_shot = false
		var bullet = bullet_scene.instantiate() as Bullet
		var direction = Vector2.from_angle(angle)
		bullet.direction = direction
		get_tree().root.add_child(bullet)
		bullet.global_position = nozzle.global_position
		
		stop_timer = stop_time
		
		heat += heat_per_shot
		
		if heat > maximum_heat:
			overheat_cooldown_timer = overheat_cooldown_time
			heat = maximum_heat
	
	if event.is_action_released("ui_accept") and overheat_cooldown_timer <= 0.0 and charged_shot_timer >= charged_shot_time and charging_shot:
		charged_shot_timer = 0.0
		charging_shot = false
		var bullet = bullet_scene.instantiate() as Bullet
		var direction = Vector2.from_angle(angle)
		bullet.direction = direction
		bullet.scale *= 2.0
		bullet.damage *= 3.0
		get_tree().root.add_child(bullet)
		bullet.global_position = nozzle.global_position
		
		stop_timer = stop_time
		
		heat += heat_per_shot * 1.5
		
		if heat > maximum_heat:
			overheat_cooldown_timer = overheat_cooldown_time
			heat = maximum_heat
			
	if event.is_action_released("ui_accept") and charged_shot_timer < charged_shot_time and charged_shot_timer > single_shot_time_threshold:
		charged_shot_timer = 0.0
		charging_shot = false
		
