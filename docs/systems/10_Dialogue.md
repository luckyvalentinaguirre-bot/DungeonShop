# 10 — Sistema de Diálogos

> Conversaciones con clientes, héroes, vecinos y en eventos. Debe soportar
> ramificación, variables y localización, manteniéndose **data-driven** y
> desacoplado de la lógica de juego. Estados: 🟢/🟡/🔴.

---

## 1. Objetivos de diseño

- Diálogos como **datos**, no código, para poder escribir contenido en masa y
  localizar (ver [localization](../../localization)).
- **Ramificación y condiciones** (mostrar líneas según reputación, arco, flags).
- Que una **elección** pueda disparar consecuencias (venta, evento, misión) vía
  señales, sin que el motor de diálogo conozca esos sistemas.

## 2. Decisión de tecnología 🔴

Dos caminos (cerrar antes de Fase 7):

1. **Plugin Dialogic** (addon maduro de Godot): rápido, editor visual, timelines.
   Riesgo: dependencia externa, integrar sus señales con nuestro `EventBus`.
2. **Motor propio ligero** basado en `DialogueData` (Resources): control total,
   encaja con nuestra arquitectura, más trabajo inicial.

**Recomendación:** empezar con motor propio mínimo (encaja con "datos en Resources"
y evita acoplarnos a un addon), y reconsiderar Dialogic si la escala de contenido lo
justifica. Documentar la decisión aquí cuando se tome.

## 3. Modelo de datos (motor propio) 🟡

- **`DialogueData`** (Resource): un "árbol"/timeline de nodos.
- **`DialogueNode`**: una línea (quién habla, texto localizable, retrato, emoción)
  + posibles **opciones**.
- **`DialogueChoice`**: texto + **condición** (para mostrarse) + **efecto** (señal/
  flag a disparar) + nodo siguiente.
- **Condiciones y efectos** son componibles (mismo patrón que [Events](07_Events.md)):
  `DialogueCondition` y `DialogueEffect` como Resources → extensible sin tocar el motor.

## 4. Variables y contexto

- El diálogo lee de un **contexto**: `GameState` (oro, día, flags), reputación,
  perfil del interlocutor. Interpolación de texto (`"Hola, {player_name}"`).
- Los efectos escriben vía **señales al `EventBus`** (p. ej. `dialogue_effect(id)`),
  que los sistemas correspondientes interpretan. El motor de diálogo **no** llama a
  economía/misiones directamente.

## 5. Presentación

- `DialogueView` (UI) muestra retrato, nombre, texto con *typewriter*, y opciones.
- Reutiliza retratos de `assets/portraits/` y el sistema de emociones del personaje.
- Localización: los textos son **claves** que se resuelven contra los CSV de
  `localization/` (nada de strings hardcodeadas en Resources salvo claves).

## 6. Modelo de clases

| Clase | Tipo | Responsabilidad |
|-------|------|-----------------|
| `DialogueData` | Resource | Árbol de diálogo |
| `DialogueNode` / `DialogueChoice` | Resource | Línea y opción |
| `DialogueCondition` / `DialogueEffect` | Resource (base) | Condición/efecto componible |
| `DialogueRunner` | system | Recorre el árbol, evalúa condiciones, emite efectos |
| `DialogueView` | ui | Presentación |

## 7. Señales (EventBus)

- `dialogue_started(speaker)`
- `dialogue_choice_selected(choice)`
- `dialogue_effect(effect_id, payload)`  ← puente hacia otros sistemas
- `dialogue_ended(speaker)`

## 8. Preguntas abiertas

- 🔴 Dialogic vs. motor propio (§2).
- 🔴 ¿Los diálogos tienen voz/*barks* aleatorios además de conversaciones completas?
- 🟡 Formato exacto de claves de localización.
