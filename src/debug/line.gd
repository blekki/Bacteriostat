class_name Line
extends RefCounted

var start: Vector2
var end: Vector2
var color: Color

func _init(start: Vector2, end: Vector2, color: Color):
	self.start = start
	self.end = end
	self.color = color
