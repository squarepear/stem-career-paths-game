extends Control

const _CAST_PATH := "res://cast/"
const _LOCATIONS_PATH := "res://locations/"
const _MAX_REDRAW_TO_PREVENT_BACK_TO_BACK := 10

@export_category("Animation")

## How long it takes a new "card" to slide in on top of the stack.
@export var slide_in_duration := 0.35

## How long it takes for the bottom card to fade out as a new card
## slides in on top of it.
@export var bottom_card_modulate_duration := 0.15


@export_category("Manual Testing")
## Forces the application to start with a particular story.
@export_file("*.gd") var starting_story

var world : World

## The number of stories completed so far
var _stories_complete := 0

var _previous_npc_name := ""

@onready var _game_screen := $GameScreen


func _ready():
	# Log the start of the game
	GameLog.start_game()
	
	# Initialize the world
	world = World.new()
	world.cast.load_cast(_CAST_PATH)
	_game_screen.world = world
	
	## Load all of the starting stories
	world.add_stories(StoryLoader.STARTING_STORIES_PATH)
	
	# Start by telling the player this is the start of freshman year
	await _game_screen.show_year_advancement(Year.Name.FRESHMAN)
	
	while _stories_complete < world.turns_per_year * 4:
		if world.available_stories.is_empty():
			# This would happen if there are no available stories to run.
			# We should design the game so that this can't happen.
			# Hence, we push an error in this case, since we have done
			# something wrong... and should probably write automated tests
			# to ensure it doesn't happen again.
			push_error("Ran out of stories!")
			break
		else:
			await _run_next_story()
			_stories_complete += 1
	
	await _game_screen.finish_game()
	var start_scene :Control = load("res://ui/start_scene.tscn").instantiate()
	owner.change_scene(start_scene)


# Draw a random story and run it.
func _run_next_story() -> void:
	var story_path : String
	var story 
	
	# Determine the next story based on whether we are forcing one or not.
	if starting_story == null:
		story_path = _draw_random_story()
		story = load(story_path).new()
		
		# Prevent back-to-back interactions with the same character,
		# unless we exceed the redraw limit. This way, if we end
		# up in a situation where the next one has to be a repeat
		# interaction, we can still move forward.
		var count := 0
		while story.npc_name == _previous_npc_name \
			and count < _MAX_REDRAW_TO_PREVENT_BACK_TO_BACK:
			story_path = _draw_random_story()
			story = load(story_path).new()
			count += 1
		
		_previous_npc_name = story.npc_name
	
	# If we are testing a particular story, go get that one, and remove
	# it from the collection if it had been there to prevent repeats.
	else:
		print("Forcing starting story: ", starting_story)
		story_path = starting_story
		story = load(story_path).new()
		
		world.available_stories.erase(starting_story)
		starting_story = null
	
	await story.run(_game_screen)
	var year_changed := world.end_turn()
	if year_changed:
		await _game_screen.show_year_advancement(world.year)


func _draw_random_story() -> String:
	var story_path : String = world.get_active_stories().pick_random()
	world.available_stories.erase(story_path)
	return story_path


func set_turns_per_year(turns: int) -> void:
	world.turns_per_year = turns
