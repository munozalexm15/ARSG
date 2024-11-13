extends RayCast3D

@export var hudNode := NodePath()
@onready var hud : HUD = get_node(hudNode)

@onready var player : Player = $"../../../.."

var lastEnemy: Player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not is_multiplayer_authority():
		return
		
	if is_colliding():
		var collision = get_collider()
		
		if collision == Ammo or collision == null:
			return
		if collision != Player and collision.get_class() != "CharacterBody3D" and collision != Bullet:
			hud.ally_indicator(Color.WHITE)
		
		elif (collision is Player and collision != player) and (collision.health > 0):
			lastEnemy = collision
			hud.ally_indicator(Color.DARK_RED)
			
		elif (lastEnemy and collision != Player and collision.visible == false) or collision == null:
			#lastEnemy.tween_healthBar_visibility()
			hud.ally_indicator(Color.WHITE)

	else:
		hud.NPCNameLabel.visible = false
		hud.NPCRoleLabel.visible = false
		player.seeing_ally = false
		hud.ally_indicator(Color.WHITE)
