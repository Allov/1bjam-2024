class_name MusicManager
extends Node2D

@onready var music_player: AudioStreamPlayer = $MusicPlayer
var combat_music = preload("res://assets/combat.ogg")
var mining_music = preload("res://assets/mining.ogg")

func play_combat_music():
	music_player.stream = combat_music
	music_player.play()
	
func play_mining_music():
	music_player.stream = mining_music
	music_player.play()
