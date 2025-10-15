extends Node

const BUTTON_PRESS_SOUND = preload("res://sounds/blipSelect.wav")
const DEATH_SOUND = preload("res://sounds/explosion.wav")
const HURT_SOUND = preload("res://sounds/hitHurt.wav")
const DEFAULT_SHOOT_SOUND = preload("res://sounds/laserShoot.wav")
const MAIN_MENU_SONG = preload("res://sounds/mainMenu.mp3") #sick bgm for the main menu btw it's so awesome (heh im so cool heh)
const GAME_SONG = preload("res://sounds/placeholderGameSong.mp3")
const PARRY_SOUND = preload("res://sounds/parry_sound.wav")
const STARTUP_SOUND = preload("res://sounds/startupSound.mp3")

var bgm_player = AudioStreamPlayer.new()

func _ready():
	pass

func play_main_menu():
	add_child(bgm_player)
	bgm_player.stream = MAIN_MENU_SONG
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
