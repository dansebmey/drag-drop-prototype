extends Node

signal mouse_pressed
signal mouse_released

@export_category("DragDropper: References")
@export var tileParent: Node3D
@export var ghost_mesh: Node3D

var _tiles: Array[Tile]
var _dragged_pieces: Array[Piece]
var _source_tile: Tile

var piece_pos: Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.on_tile_selected.connect(s_update_ghost_mesh)
	SignalBus.on_piece_landed.connect(toggle_ghost_mesh.bind(false))
	
	for tile in tileParent.get_children():
		_tiles.append(tile)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_update_dragged_pieces()

func _update_dragged_pieces():
	if _dragged_pieces.size() == 0: return
	
	if _dragged_pieces[0].is_following_mouse:
		var cam = get_viewport().get_camera_3d()
		var mouse_pos = get_viewport().get_mouse_position()
		
		var plane = Plane(Vector3.UP, Vector3(0, 0.35, 0))
		var result = plane.intersects_ray(cam.project_ray_origin(mouse_pos), cam.project_ray_normal(mouse_pos))
		
		if result != null:
			for piece in _dragged_pieces:
				var x = clamp(result.x, -1.5, 2.5)
				var z = clamp(result.z, -5, 5)
				piece.target_pos = Vector3(x, piece.global_position.y, z)
		else:
			toggle_ghost_mesh(false)

func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		for tile in _tiles:
			var _pieces_to_drag = tile.try_anim_lift_pieces().duplicate()
			if _pieces_to_drag.size() > 0:
				_dragged_pieces = _pieces_to_drag
				_source_tile = tile
				toggle_ghost_mesh(true)
	elif event is InputEventMouseButton and event.is_released() and event.button_index == MOUSE_BUTTON_LEFT:
		var found = false
		if _dragged_pieces.size() > 0:
			for tile in _tiles:
				if tile != _source_tile and tile.try_register_pieces(_dragged_pieces):
					_source_tile.remove_pieces(_dragged_pieces)
					found = true
			
			if !found:
				_source_tile.anim_return_pieces()
				toggle_ghost_mesh(false)
			
			_dragged_pieces.clear()

func toggle_ghost_mesh(enable: bool):
	ghost_mesh.visible = enable

func s_update_ghost_mesh(tile: Tile):
	if _dragged_pieces.size() == 0: return
	
	var pos = tile.global_position
	var y = pos.y + 0.1
	if tile != _source_tile:
		y += tile.pieces.size() * 0.15
	
	ghost_mesh.global_position = Vector3(pos.x, y, pos.z)
