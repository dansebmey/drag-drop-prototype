class_name Tile
extends Node

signal mouse_pressed
signal mouse_released

@export var pieces: Array[Piece]
@export var mesh: CSGMesh3D
@export var mat_default: Material
@export var mat_highlight: Material
@export var max_pieces_dragged: int = 7

var _is_mouse_in_area = false

func try_anim_lift_pieces() -> Array[Piece]:
	if !_is_mouse_in_area: return []
	
	var _pieces_to_drag = get_pieces_to_drag().duplicate()
	if _pieces_to_drag.size() > 0:
		for _piece in _pieces_to_drag:
			_piece.anim_lift()
	
	return _pieces_to_drag

func try_register_pieces(_new_pieces: Array[Piece]) -> bool:
	if _is_mouse_in_area:
		return register_pieces(_new_pieces)
	else:
		return false

func register_pieces(_new_pieces: Array[Piece]) -> bool:
	for i in _new_pieces.size():
		var appended_index = i + pieces.size()
		_new_pieces[i].set_index(appended_index)
		_new_pieces[i].anim_drop(self)
	
	pieces.append_array(_new_pieces)
	return true

func anim_return_pieces():
	for i in pieces.size():
		pieces[i].set_index(i)
		pieces[i].anim_drop(self)

func _on_tile_area_mouse_entered():
	_is_mouse_in_area = true
	mesh.material = mat_highlight
	SignalBus.on_tile_selected.emit(self)

func _on_tile_area_mouse_exited():
	_is_mouse_in_area = false
	mesh.material = mat_default

func get_pieces_to_drag() -> Array[Piece]:
	return pieces.slice(clamp(pieces.size() - max_pieces_dragged, 0, 7), pieces.size())

func remove_pieces(_pieces_to_remove: Array[Piece]):
	for piece in _pieces_to_remove:
		if pieces.has(piece):
			pieces.erase(piece)
