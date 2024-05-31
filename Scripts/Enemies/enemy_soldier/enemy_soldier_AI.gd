extends CharacterBody3D

@export var navRegionNode := NodePath()
@onready var navRegion :  NavigationRegion3D = get_node(navRegionNode)

@onready var navAgent : NavigationAgent3D = $NavigationAgent

var speed = 2
var acceleration = 30

var closest_cover = null
var last_cover = null
var enemy : CharacterBody3D = null

var next_pos = null

##BEHAVIOR:
# FIND COVER
## IF PLAYER IS TO CLOSE, FIND ANOTHER CLOSE COVER


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var direction = Vector3()
	
	if next_pos:
		direction = move_to(next_pos.position)
		velocity = velocity.lerp(direction * speed, acceleration * delta)
	
	move_and_slide()

func _on_cover_detection_area_body_entered(body):
	if body is Cover:
		if closest_cover == null:
			last_cover = body
		last_cover = closest_cover
		closest_cover = body
	
	next_pos = closest_cover

func _on_enemy_detection_area_body_entered(body):
	if body is Player:
		enemy = body
		next_pos = enemy

func move_to(position):
	var direction = Vector3()
	navAgent.target_position = position
		
	direction = navAgent.get_next_path_position() - global_position
	direction = direction.normalized()
	
	return direction
