extends Control


const TAROT_EFFECTS = ["HEAL_SMALL", "DAMAGE_BOOST", "RANGE_BUFF", "FIRERATE_BUFF"]

func _ready():
	$Card1.connect("pressed", Callable(self, "pick_card").bind(0))
	$Card2.connect("pressed", Callable(self, "pick_card").bind(1))
	$Card3.connect("pressed", Callable(self, "pick_card").bind(2))
	
	$Card1.disabled = false
	$Card2.disabled = false
	$Card3.disabled = false
	
func pick_card(card_index):
	$Card1.disabled = true
	$Card2.disabled = true
	$Card3.disabled = true
	var chosen_effect = TAROT_EFFECTS[randi() % TAROT_EFFECTS.size()]
	FortuneManager.fortune_given.emit(chosen_effect)
	
