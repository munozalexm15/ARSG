extends StaticBody3D
class_name Target

signal hitmark

@export var targetData : HumanTargetData

@onready var animationPlayer: AnimationPlayer = $"../../../AnimationPlayer"
@onready var headArea: Area3D = $"../HeadArea"

var isHeadshot : bool = false
# Called when the node enters the scene tree for the first time.
var isDowned
func _ready():
	isDowned = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if targetData.actualHealth <= 0 and not isDowned:
		animationPlayer.play("Down")
		isDowned = true

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Down":
		await get_tree().create_timer(targetData.downTime).timeout
		animationPlayer.play("Up")
		isHeadshot = false
	
	if anim_name == "Up":
		isDowned = false
		targetData.actualHealth = targetData.health


func _on_head_area_body_entered(body):
	if body is Bullet:
		targetData.actualHealth -= body.damage
