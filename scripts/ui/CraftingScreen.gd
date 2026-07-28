extends Control
## Pantalla de fabricación: elige una receta y los materiales (con sus rasgos) del
## stock, y crea el objeto, que se añade al stock para venderlo. Muestra en vivo cómo
## los materiales elegidos determinan la calidad/perfil. Ver docs/systems/05_Crafting.md.

var _gold_label: Label
var _recipe_box: VBoxContainer
var _materials_box: VBoxContainer
var _selection_label: Label
var _info_label: Label
var _craft_btn: Button
var _log: RichTextLabel

var _selected_recipe: RecipeData
var _selection: Array = []  # ItemInstance (unidades elegidas)

func _ready() -> void:
	if GameState.economy == null:
		GameState.new_game()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	UiFactory.background(self)
	_build_ui()
	_refresh_all()

func _build_ui() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	add_child(margin)

	var root := UiFactory.vbox(12)
	margin.add_child(root)

	# HUD
	var hud := UiFactory.panel()
	var hud_row := UiFactory.hbox(20)
	hud.add_child(hud_row)
	hud_row.add_child(UiFactory.label("Fabricación", 22, UiFactory.COL_ACCENT))
	_gold_label = UiFactory.label("Oro: 0", 18)
	hud_row.add_child(_gold_label)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hud_row.add_child(spacer)
	var back := UiFactory.button("Volver a la tienda")
	back.pressed.connect(func() -> void: SceneRouter.goto_shop())
	hud_row.add_child(back)
	root.add_child(hud)

	# Cuerpo: recetas | selección | materiales
	var body := UiFactory.hbox(12)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(body)
	body.add_child(_build_recipes_panel())
	body.add_child(_build_selection_panel())
	body.add_child(_build_materials_panel())

	# Log
	var log_panel := UiFactory.panel()
	log_panel.custom_minimum_size = Vector2(0, 120)
	_log = RichTextLabel.new()
	_log.bbcode_enabled = true
	_log.scroll_following = true
	_log.add_theme_color_override("default_color", UiFactory.COL_TEXT)
	log_panel.add_child(_log)
	root.add_child(log_panel)

func _build_recipes_panel() -> Control:
	var panel := UiFactory.panel()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var box := UiFactory.vbox(6)
	panel.add_child(box)
	box.add_child(UiFactory.label("Recetas", 18, UiFactory.COL_ACCENT))
	_recipe_box = UiFactory.vbox(6)
	box.add_child(_recipe_box)
	return panel

func _build_selection_panel() -> Control:
	var panel := UiFactory.panel()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var box := UiFactory.vbox(8)
	panel.add_child(box)
	box.add_child(UiFactory.label("Taller", 18, UiFactory.COL_ACCENT))
	_info_label = UiFactory.label("Elige una receta.", 15)
	box.add_child(_info_label)
	_selection_label = UiFactory.label("Materiales elegidos: (ninguno)", 15)
	box.add_child(_selection_label)
	var clear_btn := UiFactory.button("Limpiar selección")
	clear_btn.pressed.connect(_clear_selection)
	box.add_child(clear_btn)
	_craft_btn = UiFactory.button("Fabricar")
	_craft_btn.disabled = true
	_craft_btn.pressed.connect(_on_craft)
	box.add_child(_craft_btn)
	return panel

func _build_materials_panel() -> Control:
	var panel := UiFactory.panel()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var box := UiFactory.vbox(6)
	panel.add_child(box)
	box.add_child(UiFactory.label("Materiales en stock", 18, UiFactory.COL_ACCENT))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	_materials_box = UiFactory.vbox(6)
	_materials_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_materials_box)
	return panel

# ------------------------------------------------------------------------ lógica
func _refresh_all() -> void:
	_gold_label.text = "Oro: %d" % GameState.gold()
	_refresh_recipes()
	_refresh_materials()
	_refresh_selection()

func _refresh_recipes() -> void:
	for c in _recipe_box.get_children():
		c.queue_free()
	var recipes := GameState.crafting.recipes()
	if recipes.is_empty():
		_recipe_box.add_child(UiFactory.label("(No hay recetas)", 14))
		return
	for recipe in recipes:
		var btn := UiFactory.button(recipe.display_name)
		btn.custom_minimum_size = Vector2(0, 34)
		btn.pressed.connect(_select_recipe.bind(recipe))
		_recipe_box.add_child(btn)

func _select_recipe(recipe: RecipeData) -> void:
	_selected_recipe = recipe
	_clear_selection()
	_info_label.text = "Receta: %s\nNecesita: %s\nProduce: %s" % [
		recipe.display_name, _slots_text(recipe), _output_name(recipe),
	]

func _refresh_materials() -> void:
	for c in _materials_box.get_children():
		c.queue_free()
	var found := false
	for slot in GameState.stock.get_items():
		if slot.data == null or slot.data.category != GameEnums.Category.MATERIAL:
			continue
		found = true
		var available := slot.quantity - _selected_count(slot.data.id)
		var btn := UiFactory.button("%s ·x%d· (+)" % [slot.data.display_name, available])
		btn.custom_minimum_size = Vector2(0, 32)
		btn.disabled = available <= 0
		btn.pressed.connect(_add_material.bind(slot))
		_materials_box.add_child(btn)
	if not found:
		_materials_box.add_child(UiFactory.label("(Sin materiales en stock)", 14))

func _add_material(slot: ItemInstance) -> void:
	if _selected_recipe == null:
		_log_line("Elige primero una receta.")
		return
	if slot.quantity - _selected_count(slot.data.id) <= 0:
		return
	_selection.append(ItemInstance.new(slot.data, slot.quality, 1))
	_refresh_selection()
	_refresh_materials()

func _clear_selection() -> void:
	_selection.clear()
	_refresh_selection()
	_refresh_materials()

func _refresh_selection() -> void:
	if _selection.is_empty():
		_selection_label.text = "Materiales elegidos: (ninguno)"
	else:
		var names: Array = []
		for m in _selection:
			names.append(m.data.display_name)
		_selection_label.text = "Materiales elegidos: " + ", ".join(names)
	_craft_btn.disabled = not CraftingResolver.satisfies(_selected_recipe, _selection)

func _on_craft() -> void:
	if _selected_recipe == null:
		return
	var result := GameState.craft(_selected_recipe, _selection)
	if result.success:
		var out := result.output
		var defect_txt := "  [color=#d98f6a](¡defectuoso!)[/color]" if out.defect else ""
		_log_line("[color=#8fd08a]Fabricaste %s (calidad %d)%s. Perfil: %s[/color]" % [
			out.data.display_name, out.quality, defect_txt, str(out.attributes),
		])
	else:
		_log_line("[color=#d98f6a]No se pudo fabricar: %s[/color]" % result.reason)
	_clear_selection()
	_refresh_all()

# ------------------------------------------------------------------------ helpers
func _selected_count(item_id: StringName) -> int:
	var n := 0
	for m in _selection:
		if m.data != null and m.data.id == item_id:
			n += 1
	return n

func _slots_text(recipe: RecipeData) -> String:
	var parts: Array = []
	var count: int = mini(recipe.required_categories.size(), recipe.required_quantities.size())
	for i in count:
		parts.append("%dx %s" % [int(recipe.required_quantities[i]), _cat_name(int(recipe.required_categories[i]))])
	return ", ".join(parts) if not parts.is_empty() else "(nada)"

func _output_name(recipe: RecipeData) -> String:
	var data := GameState.item_db.get_item(recipe.output_item_id)
	return data.display_name if data != null else str(recipe.output_item_id)

func _log_line(text: String) -> void:
	if _log != null:
		_log.append_text(text + "\n")

func _cat_name(category: int) -> String:
	match category:
		GameEnums.Category.WEAPON: return "arma"
		GameEnums.Category.ARMOR: return "armadura"
		GameEnums.Category.POTION: return "poción"
		GameEnums.Category.TOOL: return "herramienta"
		GameEnums.Category.MAGIC: return "objeto mágico"
		GameEnums.Category.MATERIAL: return "material"
		_: return "objeto"
