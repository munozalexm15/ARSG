extends StaticBody3D
class_name Target

signal hitmark

@export var targetData : HumanTargetData

@onready var animationPlayer: AnimationPlayer = $"../../../AnimationPlayer"
@onready var headArea: Area3D = $"../HeadArea"

@onready var healthBar : ProgressBar = $"../../../SubViewport/ProgressBar"

var isHeadshot : bool = false
# Called when the node enters the scene tree for the first time.
var isDowned
func _ready():
	isDowned = false
	healthBar.value = targetData.actualHealth

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if targetData.actualHealth == targetData.health or targetData.actualHealth <= 0:
		healthBar.visible = false
	else:
		healthBar.visible = true
	
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
		if targetData.actualHealth < 0 and body.instigator.hud.timerContainer.visible:
			body.instigator.hud.pointsLabel.text = str(int(body.instigator.hud.pointsLabel.text) + 15)
