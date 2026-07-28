extends Control
## Menú principal: título e inicio de partida. Construye su UI por código sobre un
## nodo raíz mínimo. Ver docs/Roadmap.md (Fase 7).

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	UiFactory.background(self)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var box := UiFactory.vbox(18)
	center.add_child(box)

	box.add_child(UiFactory.title("Dungeon Shop"))
	var subtitle := UiFactory.label("No eres el héroe. Eres quien lo equipa.", 16, UiFactory.COL_ARCANE)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(subtitle)

	box.add_child(_spacer(20))

	var new_game_btn := UiFactory.button("Nueva partida")
	new_game_btn.pressed.connect(_on_new_game)
	box.add_child(new_game_btn)

	var continue_btn := UiFactory.button("Continuar")
	continue_btn.disabled = not SaveManager.has_save(1)
	continue_btn.pressed.connect(_on_continue)
	box.add_child(continue_btn)

	var quit_btn := UiFactory.button("Salir")
	quit_btn.pressed.connect(_on_quit)
	box.add_child(quit_btn)

func _on_new_game() -> void:
	GameState.new_game()
	SceneRouter.goto_counter()

func _on_continue() -> void:
	if SaveManager.load_game(1):
		SceneRouter.goto_counter()

func _on_quit() -> void:
	get_tree().quit()

func _spacer(height: int) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, height)
	return c
