extends Test
## Tests de DialogueRunner. Ver docs/systems/10_Dialogue.md.

func _line(speaker: String, text: String) -> DialogueLine:
	var l := DialogueLine.new()
	l.speaker = speaker
	l.text = text
	return l

func _dialogue() -> DialogueData:
	var d := DialogueData.new()
	d.lines = [_line("Mabel", "¡Hola!"), _line("Mabel", "¿Tienes pociones?")]
	return d

func test_advances_through_lines() -> void:
	var r := DialogueRunner.new()
	r.start(_dialogue())
	assert_true(r.has_next())
	var first := r.advance()
	assert_eq(first.text, "¡Hola!")
	var second := r.advance()
	assert_eq(second.speaker, "Mabel")
	assert_eq(second.text, "¿Tienes pociones?")

func test_finishes_after_last_line() -> void:
	var r := DialogueRunner.new()
	r.start(_dialogue())
	r.advance()
	r.advance()
	assert_false(r.has_next())
	assert_true(r.is_finished())
	assert_true(r.advance() == null, "no hay más líneas")

func test_empty_dialogue() -> void:
	var r := DialogueRunner.new()
	r.start(DialogueData.new())
	assert_false(r.has_next())
