class_name Bug
extends CharacterBody2D

signal dead

@export var target = Vector2.ZERO
@export var speed = 10.0
@export var max_health = 30
@export var stagger_time = .6
@export var attack_time = 1.0
@export var damage = 10
@onready var health_bar: ProgressBar = $HealthBar
@onready var hurt_box: Area2D = $HurtBox
@onready var sprite: Sprite2D = $Sprite

var health = max_health
var stagger_timer = 0.0
var attack_timer = 0.0
var can_damage_dome = false
var dome: Dome


func _ready() -> void:
	health_bar.value = health
	health_bar.visible = false
	
	hurt_box.body_entered.connect(_on_hurt_box_body_entered)

func hit(damage: int):
	health -= damage
	if health < 0:
		dead.emit()
		queue_free()
		
	stagger_timer = stagger_time

func _physics_process(delta: float) -> void:
	if health < max_health:
		health_bar.value = health
		health_bar.visible = true
		
		
	var direction = (target - global_position).normalized()
	
	stagger_timer -= delta
	if stagger_timer > 0.0:
		direction = Vector2.ZERO
		
	if can_damage_dome and is_instance_valid(dome):
		attack_timer -= delta
		
		if attack_timer < 0.0:
			attack_timer = attack_time
			dome.hit(damage)
	
	if direction:
		velocity = direction * speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)

	if direction.x > 0:
		sprite.flip_h = true
	elif direction.x < 0:
		sprite.flip_h = false

	move_and_slide()

func _on_hurt_box_body_entered(node: Node2D):
	dome = node as Dome
	can_damage_dome = true
