extends Skeleton3D

@onready var right_bone_index = find_bone("UpperArm.R")
@onready var left_bone_index = find_bone("UpperArm.L")

@onready var lower_right_bone_index = find_bone("LowerArm.R")
@onready var lower_left_bone_index = find_bone("LowerArm.L")
@onready var hand_left_index = find_bone("Hand.L")
@onready var hand_right_index = find_bone("Hand.R")

@onready var neck_bone_index = find_bone("Neck")
@onready var chest_bone_index = find_bone("Chest")

@onready var left_org_bone_rot: Quaternion = get_bone_pose_rotation(hand_left_index)
@onready var right_org_bone_rot: Quaternion = get_bone_pose_rotation(hand_right_index)

@onready var neck_org_bone_rot: Quaternion = get_bone_pose_rotation(neck_bone_index)
@onready var chest_org_bone_rot: Quaternion = get_bone_pose_rotation(chest_bone_index)

@onready var head_bone_index = find_bone("Head")
@onready var head_org_bone_rot: Quaternion = get_bone_pose_rotation(head_bone_index)

@onready var skeletonRoot : PlayerSkeleton = $"../../.."

var eyesHolder : Node3D = null
var arms : Arms = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#rotate_arms_bone(chest_bone_index, chest_org_bone_rot)
	#rotate_arms_bone(hand_left_index, left_org_bone_rot)
	rotate_arms_bone(neck_bone_index, neck_org_bone_rot)

func rotate_arms_bone(bone_index, org_bone_rot):
	var bone_rotation: Quaternion = get_bone_pose_rotation(bone_index)
	var bone_parent_bones_rotation: Quaternion = get_bone_global_pose_no_override(bone_index).basis.get_rotation_quaternion() * bone_rotation.normalized().inverse()
	var skeleton_global_rotation: Quaternion = transform.basis.get_rotation_quaternion()
	var bone_parents_rotation: Quaternion = skeleton_global_rotation * bone_parent_bones_rotation
	var bone_global_rotation: Quaternion = bone_parents_rotation * org_bone_rot

	var new_bone_global_rotation: Quaternion = Quaternion(Vector3.LEFT, eyesHolder.rotation.x) * bone_global_rotation
	var new_bone_rotation: Quaternion = bone_parents_rotation.inverse() * new_bone_global_rotation

	set_bone_pose_rotation(bone_index, new_bone_rotation)
