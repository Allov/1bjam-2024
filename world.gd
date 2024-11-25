class_name World
extends Node2D

enum ControlModes {
	GUN_TURRET,
	DRILL,
	SHOP
}

@export var control_mode = ControlModes.DRILL
@onready var gun_turret: GunTurret = $GunTurret
@onready var drill: Drill = $Drill
@onready var dome_camera: Camera2D = $Dome/DomeCamera
@onready var drill_bore_camera: Camera2D = $Drill/DrillBore/DrillBoreCamera
@onready var wave_manager: WaveManager = $WaveManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_mode(control_mode)
	drill.home_reached.connect(_drill_reached_home)
	wave_manager.wave_ready.connect(_wave_ready)
	wave_manager.wave_finished.connect(_wave_finished)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func change_mode(new_control_mode: ControlModes):
	control_mode = new_control_mode
	
	gun_turret.disabled = control_mode != ControlModes.GUN_TURRET
	drill.disabled = control_mode != ControlModes.DRILL

	if control_mode == ControlModes.GUN_TURRET:
		dome_camera.make_current()
		MusicManagerInstance.play_combat_music()
	elif control_mode == ControlModes.DRILL:
		drill_bore_camera.make_current()
		MusicManagerInstance.play_mining_music()

func _drill_reached_home():
	change_mode(ControlModes.GUN_TURRET)
	wave_manager.start_wave()

func _wave_ready():
	drill.return_home()

func _wave_finished():
	change_mode(ControlModes.DRILL)
