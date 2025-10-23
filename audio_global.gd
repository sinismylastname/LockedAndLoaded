extends Node

const BUTTON_PRESS_SOUND = preload("res://sounds/blipSelect.wav")
const DEATH_SOUND = preload("res://sounds/explosion.wav")
const HURT_SOUND = preload("res://sounds/hitHurt.wav")
const DEFAULT_SHOOT_SOUND = preload("res://sounds/laserShoot.wav")
const MAIN_MENU_SONG = preload("res://sounds/mainMenu.mp3") #sick bgm for the main menu btw it's so awesome (heh im so cool heh)
const GAME_SONG = preload("res://sounds/PENUMBRA PHANTASM.mp3")
const PARRY_SOUND = preload("res://sounds/parry_sound.wav")
const STARTUP_SOUND = preload("res://sounds/startupSound.mp3")
const LEVELUP_SOUND = preload("res://sounds/level_up_sfx.wav")


var bgm_player = AudioStreamPlayer.new()
var button_connected = false

func play_main_menu():
	add_child(bgm_player)
	bgm_player.stream = MAIN_MENU_SONG
	bgm_player.play()

func stop_bgm():
	if bgm_player.playing:
		bgm_player.stop()

func play_game_song():
	stop_bgm()
	bgm_player.stream = GAME_SONG
	bgm_player.play()
	
func play_sfx(sound_stream: AudioStream):
	var sfx_player = AudioStreamPlayer.new() #ok so basically i have to make a new sfx_player for every sfx BECAUSE previously if you had a crazy firerate then you could literally override every noise in the game and it would literally sousnd like dogwater. not even joking it would actually just destroy your ears in the worst way ever...
	add_child(sfx_player)
	sfx_player.stream = sound_stream
	sfx_player.play()
	sfx_player.connect("finished", Callable(sfx_player, "queue_free"))

func play_click():
	play_sfx(BUTTON_PRESS_SOUND)

func play_death():
	play_sfx(DEATH_SOUND)

func play_hurt():
	play_sfx(HURT_SOUND)

func play_default_shoot_sound():
	play_sfx(DEFAULT_SHOOT_SOUND)

func play_parry():
	play_sfx(PARRY_SOUND)

func play_start_up():
	play_sfx(STARTUP_SOUND)

func play_level_up():
	play_sfx(LEVELUP_SOUND)

func _process(delta: float) -> void:
	for button in get_tree().get_nodes_in_group("buttons"):
		if button_connected == true:
			return
		button.connect("pressed", Callable(AudioGlobal, "play_click"))
		button_connected = true
		
		
