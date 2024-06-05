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
func _process(delta):
	if is_colliding():
		var collision = get_collider()
		
		if collision is FiringRange_NPC:
			npcData = collision.npcData
			player.seeing_ally = true
			
			hud.NPCNameLabel.text = npcData.name
			hud.NPCRoleLabel.text = npcData.role
			
			hud.NPCNameLabel.visible = true
			hud.NPCRoleLabel.visible = true
		else:
			hud.NPCNameLabel.visible = false
			hud.NPCRoleLabel.visible = false
			player.seeing_ally = false
		
		if collision is Target and collision.targetData.actualHealth > 0 and collision.targetData.actualHealth != collision.targetData.health:
			collision.healthBar.visible = true
			lastEnemy = collision
			
		elif collision != Target and lastEnemy:
			lastEnemy.healthBar.visible = false

	else:
		hud.NPCNameLabel.visible = false
		hud.NPCRoleLabel.visible = false
		player.seeing_ally = false
		
