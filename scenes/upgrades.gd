extends CanvasLayer

@onready var panel_nodes = [
	$Control/CenterContainer/HBoxContainer/PanelA/Upgrade,
	$Control/CenterContainer/HBoxContainer/PanelB/Upgrade,
	$Control/CenterContainer/HBoxContainer/PanelC/Upgrade
]


func _ready() -> void:
	print("Upgrades ready")
	hide()
	Global.connect("offer_upgrades", Callable(self, "_on_offer_upgrades"))
	print("Connected to Global.offer_upgrades")
	for p in panel_nodes:
		var btn: Button = p.get_node("SelectButton")
		if not is_instance_valid(btn):
			push_error("UpgradeUI Error: Panel " + p.name + " is missing a child named 'SelectButton'.")
			continue
		btn.pressed.connect(Callable(self, "_on_select_pressed").bind(p))

func _on_offer_upgrades(choices: Array) -> void:
	_show_choices(choices)
	get_tree().paused = true
	show()

func _show_choices(choices: Array) -> void:
	for i in range(panel_nodes.size()):
		var p = panel_nodes[i]
		if i < choices.size():
			var c = choices[i]
			p.visible = true

			var name_label = p.get_node("LabelName")
			var desc_label = p.get_node("LabelDesc")
			var stat_label = p.get_node("LabelStat")
			var icon_node = p.get_node("Icon")

			name_label.text = c.get("name", c.get("stat", "Stat"))
			desc_label.text = c.get("desc", "")
			stat_label.text = c.get("display", "")

			if c.has("icon") and c["icon"] != null:
				icon_node.texture = c["icon"]
			else:
				icon_node.texture = null

			p.set_meta("choice_data", c)
		else:
			p.visible = false

func _on_select_pressed(panel: Control) -> void:
	var choice = panel.get_meta("choice_data")
	
	if choice == null:
		push_error("UpgradeUI Error: Selected panel is missing 'choice_data' meta.")
		_close_modal()
		return
	_close_modal() 
	Global.apply_upgrade_choice(choice)

func _close_modal() -> void:
	hide()
	get_tree().paused = false
