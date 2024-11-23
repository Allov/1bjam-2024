class_name Dome
extends StaticBody2D

@export var max_health = 500.0
@export var gun_turret: GunTurret
@onready var health_bar: ProgressBar = $HealthBar
@onready var gun_turret_heat: ProgressBar = $GunTurretHeat

var health = max_health

func hit(damage: int):
	health -= damage
	
	if health < 0.0:
		queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_bar.value = health
	health_bar.visible = false
	health_bar.max_value = health
	gun_turret_heat.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if health < max_health:
		health_bar.value = health
		health_bar.visible = true
		
	if gun_turret.heat > 0.0:
		gun_turret_heat.value = gun_turret.heat
		gun_turret_heat.visible = true
	else:
		gun_turret_heat.visible = false
