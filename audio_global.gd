extends Node

const BUTTON_PRESS_SOUND = preload("res://sounds/blipSelect.wav") 
const DEATH_SOUND = preload("res://sounds/explosion.wav")
const HURT_SOUND = preload("res://sounds/hitHurt.wav")
const DEFAULT_SHOOT_SOUND = preload("res://sounds/laserShoot.wav")
const GAME_SONG = preload("res://sounds/placeholderGameSong.mp3")

var audio_player = AudioStreamPlayer.new()
var bgm_player = AudioStreamPlayer.new()

func _ready():
	add_child(audio_player)
	add_child(bgm_player)
	
	bgm_player.stream = GAME_SONG
	bgm_player.play()

func play_sfx(sound_stream: AudioStream):
	audio_player.stream = sound_stream
	
	if audio_player.playing:
		audio_player.stop()
	audio_player.play()

func play_click():
	play_sfx(BUTTON_PRESS_SOUND)

func play_death():
	play_sfx(DEATH_SOUND)

func play_hurt():
	play_sfx(HURT_SOUND)

func play_default_shoot_sound():
	play_sfx(DEFAULT_SHOOT_SOUND)
