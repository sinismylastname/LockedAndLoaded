extends "res://scripts/player.gd"
#plans for sniper class:
#add instant firing projectiles. basically they are straight up BEAMS of power
#also add faster spinning and stronger aim assist power?
#i mean i want it to freakin snipe, but should i give it infinite pierce? seems like it'd be freakin op

func _ready():
	super._ready()
	finalFireRate *= 0.5
	finalDamage *= 2
	finalHealth *= 0.75
