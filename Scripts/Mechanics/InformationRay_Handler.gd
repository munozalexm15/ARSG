extends RayCast3D

@export var hudNode := NodePath()
@onready var hud : HUD = get_node(hudNode)

var npcData : NPCData

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_colliding():
		var collision = get_collider()
		if not (collision is FiringRange_NPC):
			hud.NPCNameLabel.visible = false
			hud.NPCRoleLabel.visible = false
			return
		npcData = collision.npcData
		
		hud.NPCNameLabel.text = npcData.name
		hud.NPCRoleLabel.text = npcData.role
		
		
		hud.NPCNameLabel.visible = true
		hud.NPCRoleLabel.visible = true
		

	else:
		hud.NPCNameLabel.visible = false
		hud.NPCRoleLabel.visible = false
