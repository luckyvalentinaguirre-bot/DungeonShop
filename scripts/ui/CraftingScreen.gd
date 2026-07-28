extends Control
## RECIPE BOOK: elige una receta (filtrable por categoría), ve los materiales
## necesarios con marca ✓/✗, aporta materiales del stock y crea el objeto, que se
## añade al stock para venderlo. Estilo pergamino/madera del mockup. Al fabricar
## muestra el popup "¡Objeto Creado!". Ver docs/systems/05_Crafting.md.

var _gold_label: Label
var _skill_label: Label
var _tabs_box: HBoxContainer
var _recipe_box: VBoxContainer
var _materials_box: VBoxContainer
var _detail_box: VBoxContainer      # cabecera del detalle (nombre, rareza, precio)
var _req_box: VBoxContainer         # checklist "Materiales necesarios"
var _selection_label: Label
var _craft_btn: Button
var _log: RichTextLabel
var _ui_root: CanvasLayer           # para popups por encima

var _selected_recipe: RecipeData
var _selection: Array = []          # ItemInstance (unidades elegidas)
var _filter_category: int = -1      # -1 = todas las categorías

# Paleta pergamino/madera.
const COL_PARCH := Color("e6d2a6")
const COL_PARCH_EDGE := Color("5b3d22")
const COL_INK := Color("3a2414")
const COL_INK_SOFT := Color("6b4a2b")
const COL_WOOD := Color("6b4526")
const COL_WOOD_HI := Color("845735")
const COL_OK := Color("2f7d32")
const COL_BAD := Color("a33125")

func _ready() -> void:
	if GameState.economy == null:
		GameState.new_game()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Fondo: ilustracion del rincon de fabricacion (mismo estilo del juego).
	var art := TextureRect.new()
	art.texture = load("res://assets/ui/crafting_art.png")
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(art)
	# Velo oscuro para que los pergaminos del Recipe Book se lean bien encima.
	var veil := ColorRect.new()
	veil.color = Color(0.14, 0.10, 0.07, 0.45)
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(veil)
	_ui_root = CanvasLayer.new()
	add_child(_ui_root)
	_build_ui()
	_refresh_all()
	GameState.skill_leveled.connect(_on_skill_leveled)

func _build_ui() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 18)
	add_child(margin)

	var root := UiFactory.vbox(12)
	margin.add_child(root)

	# Cabecera.
	var hud := _parch_container()
	var hud_row := UiFactory.hbox(20)
	hud.add_child(hud_row)
	hud_row.add_child(_ink("Recipe Book", 24, COL_INK))
	_gold_label = _ink("Oro: 0", 18, COL_INK)
	hud_row.add_child(_gold_label)
	_skill_label = _ink("Herrería: Nv 1", 18, COL_INK)
	hud_row.add_child(_skill_label)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hud_row.add_child(spacer)
	var back := _wood_btn("Volver a la tienda")
	back.pressed.connect(func() -> void: SceneRouter.goto_counter())
	hud_row.add_child(back)
	root.add_child(hud)

	# Cuerpo: [categorías + recetas]  |  [detalle + materiales]
	var body := UiFactory.hbox(12)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(body)
	body.add_child(_build_left_page())
	body.add_child(_build_right_page())

	# Log.
	var log_panel := _parch_container()
	log_panel.custom_minimum_size = Vector2(0, 96)
	_log = RichTextLabel.new()
	_log.bbcode_enabled = true
	_log.scroll_following = true
	_log.add_theme_color_override("default_color", COL_INK)
	log_panel.add_child(_log)
	root.add_child(log_panel)

# --- página izquierda: pestañas de categoría + lista de recetas -------------
func _build_left_page() -> Control:
	var panel := _parch_container()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var box := UiFactory.vbox(8)
	panel.add_child(box)

	_tabs_box = UiFactory.hbox(4)
	box.add_child(_tabs_box)
	_add_tab("Todo", -1)
	_add_tab("Armas", GameEnums.Category.WEAPON)
	_add_tab("Armaduras", GameEnums.Category.ARMOR)
	_add_tab("Pociones", GameEnums.Category.POTION)
	_add_tab("Mágicos", GameEnums.Category.MAGIC)

	box.add_child(_ink("Recetas", 18, COL_INK))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	_recipe_box = UiFactory.vbox(6)
	_recipe_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_recipe_box)
	return panel

func _add_tab(text: String, category: int) -> void:
	var b := _wood_btn(text)
	b.custom_minimum_size = Vector2(0, 32)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.pressed.connect(func() -> void:
		_filter_category = category
		_refresh_recipes())
	_tabs_box.add_child(b)

# --- página derecha: detalle de la receta + materiales del stock -----------
func _build_right_page() -> Control:
	var panel := _parch_container()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var box := UiFactory.vbox(8)
	panel.add_child(box)

	_detail_box = UiFactory.vbox(2)
	box.add_child(_detail_box)
	_detail_box.add_child(_ink("Elige una receta.", 16, COL_INK))

	box.add_child(_ink("Materiales necesarios", 16, COL_INK))
	_req_box = UiFactory.vbox(2)
	box.add_child(_req_box)

	_selection_label = _ink("Aportados: (ninguno)", 14, COL_INK_SOFT)
	box.add_child(_selection_label)

	var row := UiFactory.hbox(8)
	box.add_child(row)
	var clear_btn := _wood_btn("Limpiar")
	clear_btn.custom_minimum_size = Vector2(110, 34)
	clear_btn.pressed.connect(_clear_selection)
	row.add_child(clear_btn)
	_craft_btn = _wood_btn("CREAR OBJETO")
	_craft_btn.custom_minimum_size = Vector2(200, 40)
	_craft_btn.disabled = true
	_craft_btn.pressed.connect(_on_craft)
	row.add_child(_craft_btn)

	box.add_child(_ink("Materiales en stock", 16, COL_INK))
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
	_refresh_skill_label()
	_refresh_recipes()
	_refresh_materials()
	_refresh_selection()

func _refresh_skill_label() -> void:
	var lvl := GameState.skills.level_of(PlayerSkills.SMITHING)
	var xp := GameState.skills.xp_of(PlayerSkills.SMITHING)
	var next := GameState.skills.xp_to_next(PlayerSkills.SMITHING)
	_skill_label.text = "Herrería: Nv %d (%d/%d)" % [lvl, xp, next]

func _on_skill_leveled(_skill_id: StringName, new_level: int) -> void:
	_log_line("[color=#3a7d32]¡Tu herrería sube al nivel %d! Mejores objetos y menos defectos.[/color]" % new_level)
	_refresh_skill_label()

func _refresh_recipes() -> void:
	for c in _recipe_box.get_children():
		c.queue_free()
	var recipes := GameState.crafting.recipes()
	var shown := 0
	for recipe in recipes:
		if _filter_category != -1 and _output_category(recipe) != _filter_category:
			continue
		shown += 1
		var lvl := recipe.required_skill_level
		var btn := _wood_btn("%s   ·   Nv %d" % [recipe.display_name, lvl])
		btn.custom_minimum_size = Vector2(0, 34)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(_select_recipe.bind(recipe))
		_recipe_box.add_child(btn)
	if shown == 0:
		_recipe_box.add_child(_ink("(No hay recetas en esta categoría)", 14, COL_INK_SOFT))

func _select_recipe(recipe: RecipeData) -> void:
	_selected_recipe = recipe
	_clear_selection()
	_refresh_detail()

func _refresh_detail() -> void:
	for c in _detail_box.get_children():
		c.queue_free()
	if _selected_recipe == null:
		_detail_box.add_child(_ink("Elige una receta.", 16, COL_INK))
		return
	var out := GameState.item_db.get_item(_selected_recipe.output_item_id)
	_detail_box.add_child(_ink(_selected_recipe.display_name, 22, COL_INK))
	if out != null:
		_detail_box.add_child(_ink("Rareza: %s   ·   Precio base: %d oro" % [_rarity_name(out.rarity), out.base_value], 14, COL_INK_SOFT))
	if _selected_recipe.required_skill_id != &"":
		var have := GameState.skills.level_of(_selected_recipe.required_skill_id)
		var col := COL_OK if have >= _selected_recipe.required_skill_level else COL_BAD
		_detail_box.add_child(_ink("Herrería requerida: Nv %d (tienes Nv %d)" % [_selected_recipe.required_skill_level, have], 14, col))
	_refresh_requirements()

## Checklist "Materiales necesarios": cada categoría requerida con ✓/✗ según lo
## aportado hasta ahora.
func _refresh_requirements() -> void:
	for c in _req_box.get_children():
		c.queue_free()
	if _selected_recipe == null:
		return
	var count: int = mini(_selected_recipe.required_categories.size(), _selected_recipe.required_quantities.size())
	for i in count:
		var cat := int(_selected_recipe.required_categories[i])
		var need := int(_selected_recipe.required_quantities[i])
		var have := _selected_category_count(cat)
		var ok := have >= need
		var mark := "✓" if ok else "✗"
		var col := COL_OK if ok else COL_BAD
		_req_box.add_child(_ink("%s  %s x%d  (aportado %d)" % [mark, _cat_name(cat), need, have], 15, col))

func _refresh_materials() -> void:
	for c in _materials_box.get_children():
		c.queue_free()
	var found := false
	for slot in GameState.stock.get_items():
		if slot.data == null or slot.data.category != GameEnums.Category.MATERIAL:
			continue
		found = true
		var available: int = int(slot.quantity) - _selected_count(slot.data.id)
		var btn := _wood_btn("%s ·x%d· (+)" % [slot.data.display_name, available])
		btn.custom_minimum_size = Vector2(0, 32)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.disabled = available <= 0
		btn.pressed.connect(_add_material.bind(slot))
		_materials_box.add_child(btn)
	if not found:
		_materials_box.add_child(_ink("(Sin materiales en stock)", 14, COL_INK_SOFT))

func _add_material(slot: ItemInstance) -> void:
	if _selected_recipe == null:
		_log_line("Elige primero una receta.")
		return
	if slot.quantity - _selected_count(slot.data.id) <= 0:
		return
	_selection.append(ItemInstance.new(slot.data, slot.quality, 1))
	_refresh_selection()
	_refresh_materials()
	_refresh_requirements()

func _clear_selection() -> void:
	_selection.clear()
	_refresh_selection()
	_refresh_materials()
	_refresh_requirements()

func _refresh_selection() -> void:
	if _selection.is_empty():
		_selection_label.text = "Aportados: (ninguno)"
	else:
		var names: Array = []
		for m in _selection:
			names.append(m.data.display_name)
		_selection_label.text = "Aportados: " + ", ".join(names)
	_craft_btn.disabled = not CraftingResolver.satisfies(_selected_recipe, _selection)

func _on_craft() -> void:
	if _selected_recipe == null:
		return
	var result := GameState.craft(_selected_recipe, _selection)
	if result.success:
		var out = result.output
		var defect_txt := "  [color=#a33125](¡defectuoso!)[/color]" if out.defect else ""
		_log_line("[color=#3a7d32]Fabricaste %s (calidad %d)%s.[/color]" % [out.data.display_name, out.quality, defect_txt])
		_show_result_popup(out)
	elif result.reason == "skill_too_low":
		_log_line("[color=#a33125]Aún no tienes herrería suficiente para esta receta.[/color]")
	else:
		_log_line("[color=#a33125]No se pudo fabricar: %s[/color]" % result.reason)
	_clear_selection()
	_refresh_all()

# --- popup "¡Objeto Creado!" -----------------------------------------------
func _show_result_popup(out) -> void:
	var vp := get_viewport_rect().size
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.5)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_ui_root.add_child(dim)

	var pop := _parch(Vector2(420, 300))
	pop.position = vp * 0.5 - Vector2(210, 150)
	dim.add_child(pop)
	var col := UiFactory.vbox(6)
	col.position = Vector2(20, 16)
	col.custom_minimum_size = Vector2(380, 0)
	pop.add_child(col)

	var title := _ink("¡Objeto Creado!", 24, COL_INK)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.custom_minimum_size = Vector2(380, 0)
	col.add_child(title)

	# Destello sobre el nombre del objeto.
	var spark := CPUParticles2D.new()
	spark.amount = 24
	spark.lifetime = 1.6
	spark.preprocess = 1.0
	spark.position = Vector2(210, 96)
	spark.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	spark.emission_sphere_radius = 60.0
	spark.gravity = Vector2.ZERO
	spark.initial_velocity_min = 6.0
	spark.initial_velocity_max = 20.0
	spark.scale_amount_min = 1.0
	spark.scale_amount_max = 3.0
	spark.color = Color(1.0, 0.9, 0.55, 0.9)
	pop.add_child(spark)

	var name_l := _ink(out.data.display_name, 22, Color("7a4a1e"))
	name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_l.custom_minimum_size = Vector2(380, 0)
	col.add_child(name_l)
	col.add_child(_center(_ink("Calidad: %d   ·   Rareza: %s" % [out.quality, _rarity_name(out.data.rarity)], 15, COL_INK)))
	var price := GameState.economy.suggested_price(out)
	col.add_child(_center(_ink("Precio sugerido: %d oro" % price, 15, COL_INK)))
	if out.defect:
		col.add_child(_center(_ink("(defectuoso: menor calidad y precio)", 13, COL_BAD)))

	var ok := _wood_btn("Continuar")
	ok.custom_minimum_size = Vector2(200, 40)
	ok.pressed.connect(func() -> void: dim.queue_free())
	var wrap := UiFactory.hbox(0)
	wrap.custom_minimum_size = Vector2(380, 0)
	wrap.alignment = BoxContainer.ALIGNMENT_CENTER
	wrap.add_child(ok)
	col.add_child(wrap)

# ------------------------------------------------------------------------ helpers
func _selected_count(item_id: StringName) -> int:
	var n := 0
	for m in _selection:
		if m.data != null and m.data.id == item_id:
			n += 1
	return n

func _selected_category_count(category: int) -> int:
	var n := 0
	for m in _selection:
		if m.data != null and m.data.category == category:
			n += 1
	return n

func _output_category(recipe: RecipeData) -> int:
	var data := GameState.item_db.get_item(recipe.output_item_id)
	return data.category if data != null else -99

func _center(l: Label) -> Label:
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.custom_minimum_size = Vector2(380, 0)
	return l

func _log_line(text: String) -> void:
	if _log != null:
		_log.append_text(text + "\n")

func _rarity_name(rarity: int) -> String:
	match rarity:
		GameEnums.Rarity.COMMON: return "Común"
		GameEnums.Rarity.UNCOMMON: return "Poco común"
		GameEnums.Rarity.RARE: return "Rara"
		GameEnums.Rarity.EPIC: return "Épica"
		GameEnums.Rarity.LEGENDARY: return "Legendaria"
		_: return "Común"

func _cat_name(category: int) -> String:
	match category:
		GameEnums.Category.WEAPON: return "arma"
		GameEnums.Category.ARMOR: return "armadura"
		GameEnums.Category.POTION: return "poción"
		GameEnums.Category.TOOL: return "herramienta"
		GameEnums.Category.MAGIC: return "objeto mágico"
		GameEnums.Category.MATERIAL: return "material"
		_: return "objeto"

# ------------------------------------------------------------------------ widgets
func _parch_container() -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", _parch_style())
	return p

func _parch(sz: Vector2) -> Panel:
	var p := Panel.new()
	p.size = sz
	p.add_theme_stylebox_override("panel", _parch_style())
	return p

func _parch_style() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = COL_PARCH
	sb.border_color = COL_PARCH_EDGE
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(8)
	sb.set_content_margin_all(12)
	sb.shadow_color = Color(0, 0, 0, 0.35)
	sb.shadow_size = 6
	return sb

func _ink(text: String, font_size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	return l

func _wood_btn(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(150, 36)
	b.add_theme_font_size_override("font_size", 16)
	b.add_theme_color_override("font_color", Color("f4e7d2"))
	b.add_theme_color_override("font_hover_color", Color("ffedcf"))
	b.add_theme_color_override("font_disabled_color", Color("9a8a72"))
	b.add_theme_stylebox_override("normal", _wood_style(COL_WOOD))
	b.add_theme_stylebox_override("hover", _wood_style(COL_WOOD_HI))
	b.add_theme_stylebox_override("pressed", _wood_style(Color("543619")))
	b.add_theme_stylebox_override("disabled", _wood_style(Color("4a3a2a")))
	return b

func _wood_style(c: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = c
	sb.border_color = Color("3a2414")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(6)
	sb.set_content_margin_all(6)
	return sb
