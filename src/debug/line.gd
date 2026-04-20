class_name Line
extends RefCounted

var start: Vector2
var end: Vector2
var color: Color

func _init(_start: Vector2, _end: Vector2, _color: Color):
	self.start = _start
	self.end = _end
	self.color = _color
