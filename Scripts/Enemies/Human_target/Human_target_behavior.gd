extends StaticBody3D
class_name Target

@warning_ignore("unused_signal")
signal hitmark

@onready var animationPlayer: AnimationPlayer = $"../../../AnimationPlayer"

var targetData : HumanTargetData = HumanTargetData.new()
var isHeadshot : bool = false
var isDowned = false

func _ready():
	targetData.health = 100
	targetData.actualHealth = 100

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	if targetData.actualHealth <= 0 and not isDowned:
		animationPlayer.play("Down")
		isDowned = true

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Down":
		await get_tree().create_timer(2).timeout
		animationPlayer.play("Up")
		isHeadshot = false
	
	if anim_name == "Up":
		isDowned = false
		targetData.actualHealth = targetData.health
