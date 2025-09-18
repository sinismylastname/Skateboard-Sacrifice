extends Control

@onready var bar = $MomentumBar
@onready var Player = null
var maxMomentum = 100

func _ready():
	call_deferred("_init_player")

func _init_player():
	Player = get_tree().get_root().get_node("World/Player")

#func _physics_process(delta):
	#if Player:
		#bar.value = clamp(Player.storedDashMomentum / Player.maxStoredMomentum * 100, 0, 100)
		
