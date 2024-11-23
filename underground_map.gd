class_name UndergroundMap
extends TileMapLayer

enum TileTypes {
	DIRT,
	WALL,
	GOLD
}
var tiles = {}
var tiles_health = {}


@export var size: Vector2 = Vector2(40, 100)
@export var explosion_scene: PackedScene
@export var mined_tile_animation: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tiles[TileTypes.WALL] = Vector2(0, 0)
	tiles[TileTypes.DIRT] = Vector2(3, 0)
	tiles[TileTypes.GOLD] = Vector2(2, 0)
	
	generate_map()
	

func generate_map():
	var source_id = tile_set.get_source_id(0)

	for y in range(size.y):
		for x in range(size.x):
			var random_tile = TileTypes.values().pick_random()
			
			var current_tile = get_cell_tile_data(Vector2(x, y))
			
			if current_tile:
				continue
			
			if y == 0:
				set_cell(Vector2(x, y), source_id, tiles[TileTypes.DIRT])
			else:
				set_cell(Vector2(x, y), source_id, tiles[random_tile])
				
			#current_tile = get_cell_tile_data(Vector2(x, y))
			#current_tile.set_custom_data("health", { "health": 100 })
			
			tiles_health[Vector2i(x, y)] = TileInfo.new()
				

func mine_at(pos: Vector2, mining_power: int):
	var local_position = to_local(pos)
	var map_position = local_to_map(local_position)
	var map_position_global_position = to_global(map_to_local(map_position))
	
	var tile_info: TileInfo = tiles_health[map_position]
	
	if tile_info.health == 100:
		var animation_sprite: Sprite2D = mined_tile_animation.instantiate()
		add_child(animation_sprite)
		animation_sprite.global_position = map_position_global_position
		tile_info.animation_sprite = animation_sprite
	
	elif tile_info.health > 75:
		tile_info.animation_sprite.frame = 1
	elif tile_info.health > 50:
		tile_info.animation_sprite.frame = 2
	elif tile_info.health > 25:
		tile_info.animation_sprite.frame = 3
	
	
	tile_info.health -= mining_power
	
	#print(tile_info.health)
	
	if tile_info.health <= 0:
		set_cell(map_position)
		
		var explosion: GPUParticles2D = explosion_scene.instantiate()
		add_child(explosion)
		
		tile_info.animation_sprite.queue_free()
		
		explosion.global_position = pos
		explosion.one_shot = true

func _process(delta: float) -> void:
	pass
