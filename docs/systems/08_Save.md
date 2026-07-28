# 08 — Sistema de Guardado

> Persistencia de la partida: guardar, cargar, autosave y compatibilidad entre
> versiones. Debe ser **robusto** (no corromper partidas) y **versionado** (poder
> actualizar el juego sin romper saves antiguos). Estados: 🟢/🟡/🔴.

---

## 1. Objetivos de diseño

- **Cero pérdida de progreso.** Escritura segura, autosave, respaldo.
- **Versionado** desde el día uno: los saves incluyen un número de versión y hay
  migraciones. Crítico para un juego comercial que recibirá parches.
- **Desacoplado:** cada sistema sabe serializar su propio estado; el `SaveManager`
  solo orquesta. (Responsabilidad única.)

## 2. Qué se guarda

- Estado de la partida (`GameState`): oro, día/semana, flags de mundo.
- Inventario (almacén + estantería).
- Reputación (prestigio + afinidades).
- Progresión (rango, mejoras, empleados, localizaciones).
- Clientes recurrentes y héroes (estado, lealtad, arcos).
- Eventos activos e historial relevante.
- Misiones y logros.
- Ajustes del jugador (se guardan aparte, no por slot).

## 3. Formato y ubicación 🟡

- Formato: **JSON** dentro de `user://saves/` (mapea a `saves/` en dev). JSON por
  legibilidad y depuración; se puede comprimir/ofuscar en release.
- Un archivo por **slot** (`slot_01.json`, …) + un `meta` con resumen (para la UI
  de "cargar partida": rango, oro, jornada, captura).
- Ajustes globales en `user://settings.cfg`.

## 4. Estrategia de serialización (desacoplada)

Cada sistema implementa un contrato implícito **`ISaveable`**:

```gdscript
## Contrato implícito (duck typing). Todo sistema persistente lo cumple.
func capture_state() -> Dictionary   ## Devuelve su estado serializable.
func restore_state(data: Dictionary) -> void  ## Se reconstruye desde datos.
```

El `SaveManager` recorre los sistemas registrados, llama a `capture_state()`,
compone un diccionario raíz con `version` + secciones, y lo escribe. Al cargar,
valida versión, migra si hace falta, y reparte cada sección a su sistema con
`restore_state()`. **El SaveManager no conoce el contenido de cada sección.**

## 5. Escritura segura (anti-corrupción)

1. Serializar a un archivo **temporal** (`slot_01.json.tmp`).
2. Validar que se escribió completo.
3. **Renombrar atómicamente** sobre el archivo real.
4. Mantener un **respaldo** del anterior (`slot_01.json.bak`).

Nunca se sobrescribe el save bueno hasta tener el nuevo íntegro en disco.

## 6. Autosave 🟡

- Autosave al **cerrar la jornada** (punto natural del bucle) y al salir del juego.
- Slot de autosave separado de los slots manuales.
- Configurable (frecuencia / on-off) en ajustes.

## 7. Versionado y migraciones

- El save raíz lleva `"version": N`.
- `SaveMigrator` aplica migraciones encadenadas (v1→v2→v3…) al cargar un save viejo.
- Regla: **nunca** cambiar el significado de un campo sin subir versión + migración.
- Los saves de versión **más nueva** que el juego se rechazan con aviso claro.

## 8. Modelo de clases

| Clase | Tipo | Responsabilidad |
|-------|------|-----------------|
| `SaveManager` | autoload | Orquesta guardar/cargar/slots/autosave; escritura segura |
| `SaveSerializer` | system (puro) | Dict ↔ JSON, validación de integridad |
| `SaveMigrator` | system (puro) | Migra saves de versiones anteriores |
| `SaveSlotMeta` | data | Resumen de un slot para la UI |
| `ISaveable` | contrato | Interfaz implícita que cumplen los sistemas |

## 9. Señales (EventBus)

- `game_saved(slot)`
- `game_loaded(slot)`
- `save_failed(reason)` (la UI avisa sin perder la sesión)

## 10. Preguntas abiertas

- 🔴 ¿JSON plano o formato binario/comprimido en release? (JSON en dev seguro).
- 🔴 Integración con **Steam Cloud** — planificar campos/rutas compatibles desde ya.
- 🟡 Número de slots manuales (recomendado 3 + autosave).
