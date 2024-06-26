class_name Piece
extends Node

const MOVE_ARC_HEIGHT = 1.0
const MOVE_DURATION = 0.5

var index = 0
var is_following_mouse = false
var target_pos: Vector3

func set_index(_index: int):
	index = _index

func _process(delta):
	if is_following_mouse:
		var tween_x = create_tween().set_trans(Tween.TRANS_CUBIC)
		var tween_z = create_tween().set_trans(Tween.TRANS_CUBIC)
		tween_x.tween_property(self, "global_position:x", target_pos.x, MOVE_DURATION * 0.1).set_ease(Tween.EASE_IN)
		tween_z.tween_property(self, "global_position:z", target_pos.z, MOVE_DURATION * 0.1).set_ease(Tween.EASE_IN)

func anim_lift():
	#self.global_position.y = 0.35
	var high_point = min(self.global_position.y + MOVE_ARC_HEIGHT, 1.35 + (index * 0.15))
	var tween_y = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween_y.tween_property(self, "global_position:y", high_point, MOVE_DURATION * 0.5).set_ease(Tween.EASE_OUT)
	
	await get_tree().create_timer(0.05).timeout
	is_following_mouse = true

func anim_drop(tile: Tile):
	is_following_mouse = false
	
	var tween_x = create_tween().set_trans(Tween.TRANS_CUBIC)
	var tween_y = create_tween().set_trans(Tween.TRANS_CUBIC)
	var tween_z = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween_x.tween_property(self, "global_position:x", tile.global_position.x, MOVE_DURATION * 0.5).set_ease(Tween.EASE_IN)
	tween_y.tween_property(self, "global_position:y", tile.global_position.y + 0.1 + (index * 0.15), MOVE_DURATION * 0.5).set_ease(Tween.EASE_IN)
	tween_z.tween_property(self, "global_position:z", tile.global_position.z, MOVE_DURATION * 0.5).set_ease(Tween.EASE_IN)
	
	await tween_x.finished
	SignalBus.on_piece_landed.emit()
