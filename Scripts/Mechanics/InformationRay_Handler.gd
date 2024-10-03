extends RayCast3D

@export var hudNode := NodePath()
@onready var hud : HUD = get_node(hudNode)

@onready var player : Player = $"../../../.."

var npcData : NPCData

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
		#if collision is Player:
			#hud.ally_indicator(Color.LAWN_GREEN)
			#player.seeing_ally = true
			#
			#hud.NPCNameLabel.text = collision.name
			#hud.NPCRoleLabel.text = "Health: " + str(collision.health)
			#
			#hud.NPCNameLabel.visible = true
			#hud.NPCRoleLabel.visible = true
		#else:
			#hud.NPCNameLabel.visible = false
			#hud.NPCRoleLabel.visible = false
			#player.seeing_ally = false
			#hud.ally_indicator(Color.WHITE)
		
		if collision is Player and collision.health > 0 and collision.visible == true:
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
