extends RayCast3D

@export var hudNode := NodePath()
@onready var hud : HUD = get_node(hudNode)

@onready var player : Player = $"../../../.."

var npcData : NPCData

var lastEnemy: Target

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not is_multiplayer_authority():
		return
		
	if is_colliding():
		var collision = get_collider()
		
		if collision is Player:
			hud.ally_indicator(Color.LAWN_GREEN)
			player.seeing_ally = true
			
			hud.NPCNameLabel.text = collision.name
			hud.NPCRoleLabel.text = "Health: " + str(collision.health)
			
			hud.NPCNameLabel.visible = true
			hud.NPCRoleLabel.visible = true
		else:
			hud.NPCNameLabel.visible = false
			hud.NPCRoleLabel.visible = false
			player.seeing_ally = false
			hud.ally_indicator(Color.WHITE)
		
		if collision is Target and collision.targetData.actualHealth > 0 and collision.targetData.actualHealth != collision.targetData.health:
			collision.healthBar.visible = true
			lastEnemy = collision
		elif lastEnemy and collision != Target:
			lastEnemy.healthBar.visible = false
			#lastEnemy.tween_healthBar_visibility()

	else:
		hud.NPCNameLabel.visible = false
		hud.NPCRoleLabel.visible = false
		player.seeing_ally = false
		hud.ally_indicator(Color.WHITE)
