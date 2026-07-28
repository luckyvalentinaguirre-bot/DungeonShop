extends Node
## Sistema de CARGA DE ASSETS (autoload). Centraliza la carga de sprites para que
## reemplazar un placeholder por el sprite final del diseñador sea trivial: se cambia
## el archivo en disco (misma ruta) o se registra un id -> ruta. Ver punto 24 del guia.
##
## Etapa 1: carga por ruta con cache y fallback. Se ampliara con un registro de
## objetos/materiales cuando entren los sprites reales (Etapa 3).

var _cache: Dictionary = {}          # ruta -> Texture2D
var _item_paths: Dictionary = {}     # id(StringName) -> ruta del sprite

## Carga (con cache) una textura por ruta res://. Devuelve null si no existe.
func texture(path: String) -> Texture2D:
	if path == "":
		return null
	if _cache.has(path):
		return _cache[path]
	var tex: Texture2D = null
	if ResourceLoader.exists(path):
		tex = load(path)
	_cache[path] = tex
	return tex

## Registra el sprite de un objeto por id (para colocar en estanterias en Etapa 3).
func register_item(id: StringName, path: String) -> void:
	_item_paths[id] = path

func item_texture(id: StringName) -> Texture2D:
	return texture(_item_paths.get(id, ""))

func has_item(id: StringName) -> bool:
	return _item_paths.has(id)
