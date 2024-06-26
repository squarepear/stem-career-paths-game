## A playable character in the game.
##
## This holds the information that is needed to run a session of the game.
class_name Character extends RefCounted

const ATTRIBUTE_NAMES : Array[String] = [
	"science",
	"technology",
	"engineering",
	"mathematics",
	"engagement",
	"resilience",
	"curiosity",
]

var science := Attribute.new()
var technology := Attribute.new()
var engineering := Attribute.new()
var mathematics := Attribute.new()

var engagement := Attribute.new()
var resilience := Attribute.new()
var curiosity := Attribute.new()

var _tags : Array[Tags.Tag] = []


## Get the names of the highest attributes
##
## If a filter is provided, only consider those attributes named in the filter.
func get_highest_attribute_names(filter : Array[String] = ATTRIBUTE_NAMES) -> Array[String]:
	var attribute_names := ATTRIBUTE_NAMES.filter(func(name): return filter.has(name))
	attribute_names.sort_custom(func(a,b): return get(a).value > get(b).value)
	var maximal_value : int = get(attribute_names[0]).value
	var result := attribute_names.filter(func(a): return get(a).value == maximal_value)
	var typed_returnable : Array[String] = []
	typed_returnable.assign(result)
	return typed_returnable


func add_tag(tag : Tags.Tag) -> void:
	_tags.append(tag)


func has_tag(tag : Tags.Tag) -> bool:
	return _tags.has(tag)


func amount_of_tag(tag : Tags.Tag) -> int:
	return _tags.count(tag)
