class_name UndergroundMap
extends TileMapLayer

enum TileTypes {
	DIRT,
	WALL,
	GOLD
}
var tiles = {}
var tiles_health = {}

@export var size: Vector2i = Vector2(40, 100)
@export var explosion_scene: PackedScene
@export var mined_tile_animation: PackedScene
@export var level_modifier = 20
@onready var tile_mined_sound: AudioStreamPlayer2D = $TileMinedSound
@onready var tile_mining_sound: AudioStreamPlayer2D = $TileMiningSound

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tiles[TileTypes.WALL] = Vector2(0, 0)
	tiles[TileTypes.DIRT] = Vector2(3, 0)
	tiles[TileTypes.GOLD] = Vector2(2, 0)
	
	generate_map()
	
func request_mining_target(pos: Vector2):
	var map_position = local_to_map(to_local(pos))
	
	var target_map_position = find_nearest_key(tiles_health, map_position)
	
	if target_map_position != null:
		return to_global(map_to_local(target_map_position))
		
	return null
	
func find_nearest_key(array: Dictionary, start: Vector2i):
	if array.is_empty():
		return null  # No keys to search
	
	# Directions in clockwise order: right, down, left, up
	var directions = [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]
	
	if randi_range(0, 1):
		directions.reverse()
		
	var step_size = 1  # Distance to travel in each direction
	var current = start  # Start at the given position
	
	# Check if the start key exists
	if array.has(current):
		return current
	
	# Spiral search
	while true:
		for direction in directions:
			for _a in range(step_size):
				current += direction
				if array.has(current):
					return current  # Found a valid key
			# Alternate step size increases after completing right-down and left-up movements
			if direction == Vector2i.UP or direction == Vector2i.DOWN:
				step_size += 1

	return null  # This point should not be reached

	

func generate_map():
	var source_id = tile_set.get_source_id(0)
	var current_level = 0

	for y in range(size.y):
		if y % level_modifier == 0:
			current_level += 1
		for x in range(size.x):
			var random_tile = TileTypes.values().pick_random()
			
			var current_tile = get_cell_tile_data(Vector2(x, y))
			
			if current_tile:
				var tile_mining_health = current_tile.get_custom_data("health")
				if tile_mining_health > 0:
					var tile_info = TileInfo.new()
					tile_info.set_health(tile_info.health * current_level)
					tiles_health[Vector2i(x, y)] = tile_info
				continue

			set_cell(Vector2(x, y), source_id, tiles[TileTypes.DIRT])
			var tile_info = TileInfo.new()
			tile_info.set_health(tile_info.health * current_level)
			tiles_health[Vector2i(x, y)] = tile_info
			
			if x == size.x / 2 - 1:
				var a = randi_range(1, 3)
				var b = randi_range(1, 3)
				
				if a == b:
					set_cell(Vector2(x, y), source_id, tiles[TileTypes.GOLD])
					var gold_tile = TileInfo.new()
					gold_tile.set_health(gold_tile.health / 2 * current_level)
					tiles_health[Vector2i(x, y)] = gold_tile
					
					set_cell(Vector2(x + 1, y), source_id, tiles[TileTypes.GOLD])
					gold_tile = TileInfo.new()
					gold_tile.set_health(gold_tile.health / 2 * current_level)
					tiles_health[Vector2i(x + 1, y)] = gold_tile
					
					set_cell(Vector2(x + 1, y + 1), source_id, tiles[TileTypes.GOLD])
					gold_tile = TileInfo.new()
					gold_tile.set_health(gold_tile.health / 2 * current_level)
					tiles_health[Vector2i(x + 1, y + 1)] = gold_tile
					
					set_cell(Vector2(x, y + 1), source_id, tiles[TileTypes.GOLD])
					gold_tile = TileInfo.new()
					gold_tile.set_health(gold_tile.health / 2 * current_level)
					tiles_health[Vector2i(x, y + 1)] = gold_tile
				
			#current_tile = get_cell_tile_data(Vector2(x, y))
			#current_tile.set_custom_data("health", { "health": 100 })
			
				

func mine_at(pos: Vector2, mining_power: int):
	var local_position = to_local(pos)
	var map_position = local_to_map(local_position)
	var map_position_global_position = to_global(map_to_local(map_position))
	
	if not tiles_health.has(map_position):
		return true
	
	var tile_info: TileInfo = tiles_health[map_position]
	
	if not tile_info.animation_sprite:
		var animation_sprite: Sprite2D = mined_tile_animation.instantiate()
		add_child(animation_sprite)
		animation_sprite.global_position = map_position_global_position
		tile_info.animation_sprite = animation_sprite
	
	elif float(tile_info.health) / float(tile_info.max_health) > .75:
		tile_info.animation_sprite.frame = 1
	elif float(tile_info.health) / float(tile_info.max_health) > .5:
		tile_info.animation_sprite.frame = 2
	elif float(tile_info.health) / float(tile_info.max_health) > .25:
		tile_info.animation_sprite.frame = 3
	
	
	tile_info.health -= mining_power
	
	#print(tile_info.health)

	if not tile_mined_sound.playing:
		tile_mined_sound.play()

	if tile_info.health <= 0:
		set_cell(map_position)
		
		var explosion: GPUParticles2D = explosion_scene.instantiate()
		add_child(explosion)
		
		tile_info.animation_sprite.queue_free()
		
		explosion.global_position = pos
		explosion.one_shot = true
		tile_mining_sound.play()
		
		tiles_health.erase(map_position)
		print("destroyed ", map_position)
		return true
		
	return false

func _process(delta: float) -> void:
	pass
