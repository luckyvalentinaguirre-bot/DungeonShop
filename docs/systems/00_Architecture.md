# 00 — Arquitectura técnica

> Cómo se organiza el código de Dungeon Shop. Este documento manda: cualquier
> script nuevo debe encajar en estas capas y convenciones. Objetivo: un proyecto
> que parezca hecho por un estudio profesional — escalable, mantenible, testeable.

---

## 1. Principios rectores

1. **Composición antes que herencia.** Los comportamientos se construyen agregando
   *nodos-componente* pequeños, no heredando jerarquías profundas. Un cliente no
   *es-un* NodoNegociable; un cliente *tiene-un* componente de negociación.
2. **SOLID donde aporte** (ver §4). No dogmatismo: aplicamos el principio cuando
   reduce el acoplamiento o el tamaño de un archivo, no por ritual.
3. **Datos fuera del código.** Objetos, recetas, clientes, héroes, eventos, etc.
   son `Resource` (`.tres`) editables en el inspector de Godot, no literales en
   `.gd`. El código *procesa* datos; los datos viven en `resources/`.
4. **Scripts pequeños.** Guía: **< 200 líneas** por script. Si crece más, casi
   siempre hay que extraer un componente o un servicio. Nada de archivos gigantes.
5. **Comunicación por señales, no por referencias directas.** Los sistemas se
   comunican vía el `EventBus` global y señales locales, no llamando a métodos de
   otros managers directamente cuando se puede evitar. Bajo acoplamiento.
6. **Todo documentado.** Cada script abre con un docstring `##` que explica su
   responsabilidad única. Cada método público lleva `##` describiendo qué hace.

## 2. Capas del proyecto

El código se organiza en **cinco capas**, de más estable (abajo) a más volátil (arriba):

```
┌──────────────────────────────────────────────────────────┐
│  UI            scenes/*, scripts/ui/                       │  Presentación. Solo muestra estado y emite intenciones.
├──────────────────────────────────────────────────────────┤
│  Managers      scripts/managers/, scripts/audio/,          │  Orquestación global (autoloads). Coordinan sistemas.
│                scripts/save/                                │
├──────────────────────────────────────────────────────────┤
│  Systems       scripts/systems/, economy/, crafting/,      │  Reglas de juego puras. Sin nodos de UI. Testeables.
│                customers/, heroes/, inventory/, events/     │
├──────────────────────────────────────────────────────────┤
│  Components    scripts/components/                          │  Piezas reutilizables que se cuelgan de escenas.
├──────────────────────────────────────────────────────────┤
│  Data          scripts/data/ (clases Resource), resources/  │  Definición de datos. Sin lógica de juego.
└──────────────────────────────────────────────────────────┘
```

**Regla de dependencia:** una capa solo puede depender de capas iguales o
inferiores. La UI depende de Systems/Data; Systems **nunca** depende de la UI.
Systems se comunica hacia arriba emitiendo señales, no llamando a la UI.

## 3. Estructura de carpetas

```
DungeonShop/
├── assets/          Arte importado (sprites, tilesets, ui, iconos, retratos, fx, fuentes…)
├── audio/           music/ (loops), ambience/ (fondos), sfx/ (efectos)
├── scenes/          Escenas .tscn agrupadas por pantalla/feature
│   ├── main_menu/   Menú principal, opciones, créditos
│   ├── shop/        La tienda: mostrador, estanterías, decoración
│   ├── crafting/    Estaciones de fabricación
│   ├── inventory/   Vistas de almacén/estantería
│   ├── market/      Compra de materiales / proveedores
│   ├── kingdom/     Mapa del reino, barrios, viajes
│   ├── tavern/      Taberna (rumores, contratar, héroes)
│   ├── customer/    Escena/plantilla de cliente en el mostrador
│   ├── hero/        Fichas y arcos de héroes
│   ├── events/      Ventanas de eventos del reino
│   ├── dialogue/    UI del sistema de diálogo
│   └── ui/          Widgets reutilizables (botones, paneles, tooltips, HUD)
├── scripts/
│   ├── managers/    Autoloads de orquestación (EventBus, GameState, SceneRouter, GameConfig)
│   ├── systems/     Servicios de reglas de juego que no encajan en una subcarpeta concreta
│   ├── components/  Componentes reutilizables (composición): Interactable, Draggable, Health…
│   ├── characters/  Base común de personajes (clientes + héroes comparten piezas)
│   ├── customers/   Lógica de clientes (generación, peticiones, negociación)
│   ├── heroes/      Lógica de héroes (expediciones, resultados, lealtad)
│   ├── inventory/   Modelo de inventario, stacks, contenedores
│   ├── economy/     Precios, mercado, transacciones, oferta/demanda
│   ├── crafting/    Estaciones, recetas, resolución de fabricación
│   ├── items/       Comportamiento de objetos (uso, calidad, rasgos)
│   ├── events/      Motor de eventos del reino
│   ├── ui/          Controladores de UI (view-models, presenters)
│   ├── save/        Serialización y persistencia
│   ├── audio/       AudioManager y buses
│   ├── data/        Clases `Resource` (ItemData, RecipeData, CustomerData, …)
│   └── utilities/   Helpers puros (matemáticas, RNG, extensiones, constantes)
├── resources/       Instancias de datos .tres (los "contenidos" del juego)
│   ├── items/  recipes/  customers/  heroes/  skills/  professions/  events/  config/
├── shaders/         .gdshader (efectos visuales)
├── localization/    CSV de traducciones (en, es, …)
├── saves/           Partidas locales (ignoradas por git)
├── docs/            Este diseño
├── addons/          Plugins de terceros del editor (GUT para tests, etc.)
├── tests/           unit/ e integration/ (framework GUT)
└── project.godot
```

**Qué NO va en cada sitio (errores comunes):**
- En `scripts/data/` no hay lógica de juego, solo `@export` y quizá helpers puros.
- En `scripts/systems/` no hay `preload` de escenas ni referencias a `$Nodo` de UI.
- En `scenes/` los `.gd` acoplados a una escena concreta pueden vivir junto al
  `.tscn`, pero la lógica reutilizable se extrae a `scripts/`.

## 4. SOLID en la práctica (con GDScript)

- **S — Responsabilidad única:** un script = una razón para cambiar. Ej.: separar
  `CustomerNeed` (qué quiere) de `HaggleResolver` (cómo se negocia el precio) de
  `CustomerView` (cómo se dibuja).
- **O — Abierto/cerrado:** el comportamiento nuevo se añade con **nuevos Resources
  y nuevos componentes**, no editando un `match` gigante. Ej.: un tipo de evento
  nuevo es un `EventData.tres` + un `EventEffect` componible, no un `case` más.
- **L — Sustitución de Liskov:** las jerarquías (pocas) respetan el contrato de la
  base. Preferimos *duck typing* por interfaz implícita + composición a herencia.
- **I — Segregación de interfaces:** componentes chicos y enfocados. Un objeto
  vendible implementa "Sellable"; uno fabricable implementa "Craftable"; no una
  mega-interfaz "Item" que lo obligue a todo.
- **D — Inversión de dependencias:** los sistemas dependen de **abstracciones**
  (Resources / señales / interfaces implícitas), no de nodos concretos. El
  `EconomySystem` no conoce la UI; emite `transaction_completed` y la UI escucha.

## 5. Patrón de comunicación: EventBus + señales

- **`EventBus` (autoload):** bus global de señales para eventos entre sistemas
  desacoplados (p. ej. `item_sold`, `reputation_changed`, `day_advanced`). Se usa
  con criterio: no para todo, solo para cruces entre features.
- **Señales locales:** dentro de una escena/feature, los nodos se comunican con
  señales propias (padre escucha a hijo). Preferido frente a `get_parent()`.
- **Regla anti-espagueti:** un sistema **emite** hacia el bus y **escucha** del bus;
  no busca a otros managers por nombre para llamarlos salvo dependencias explícitas
  declaradas (ver §6).

## 6. Autoloads (singletons) — el único estado global permitido

Declarados en `project.godot`, en orden de dependencia:

| Autoload | Responsabilidad | Depende de |
|----------|-----------------|-----------|
| `EventBus` | Señales globales entre sistemas | — |
| `GameConfig` | Constantes/tuning cargados de `resources/config/` | — |
| `SaveManager` | Guardar/cargar partida, slots, autosave | GameConfig |
| `GameState` | Estado de la partida en curso (oro, día, flags, mundo) | EventBus, SaveManager |
| `AudioManager` | Reproducción de música/sfx, buses, volúmenes | GameConfig |
| `SceneRouter` | Cambio de escena, transiciones, pila de pantallas | EventBus |

Ningún otro global. Todo lo demás se instancia dentro de escenas y se compone.

## 7. Composición: catálogo de componentes reutilizables

Los componentes viven en `scripts/components/` y se **agregan como nodos hijos** a
cualquier escena que necesite ese comportamiento. Ejemplos previstos:

| Componente | Qué añade | Lo usan |
|------------|-----------|---------|
| `InteractableComponent` | "se puede hacer clic/interactuar" + señal `interacted` | mostrador, estanterías, NPCs |
| `DraggableComponent` | arrastrar/soltar objetos | inventario, colocar stock |
| `TooltipComponent` | muestra descripción al pasar el ratón | objetos, botones |
| `InventoryComponent` | contiene un `Inventory` (stacks, capacidad) | tienda, cliente, héroe |
| `WalletComponent` | oro y transacciones | jugador, cliente, héroe |
| `MoodComponent` | estado de ánimo/paciencia | clientes |
| `ReputationComponent` | aporta a la reputación | tienda, facciones |
| `HighlightComponent` | resaltado visual al enfocar | interactuables |

Un cliente en el mostrador = `CharacterView` + `InteractableComponent` +
`WalletComponent` + `MoodComponent` + un `CustomerNeed` (dato). Cero herencia.

## 8. Convenciones de código (GDScript)

- **Nombres de archivo:** `PascalCase.gd` para scripts que definen una clase/nodo
  (`EconomySystem.gd`), `snake_case` para escenas de instancia si aplica. Carpetas
  en `snake_case`.
- **`class_name`:** los tipos reutilizables declaran `class_name` para tipado fuerte.
- **Tipado estático siempre** que se pueda: `func price_of(item: ItemData) -> int:`.
- **`@export` para datos**; nada de números mágicos en la lógica — van a `GameConfig`
  o a un `Resource`.
- **Señales en pasado:** `item_sold`, `day_advanced`, `reputation_changed`.
- **Privado por convención:** prefijo `_` en métodos/vars internos.
- **Docstrings `##`:** obligatorio en cabecera de script y métodos públicos; Godot
  los muestra en el editor.
- **Sin `get_node` por rutas frágiles** en lógica: usar `@onready` con `@export`
  de `NodePath` o inyección por escena.

Plantilla de cabecera de script:
```gdscript
class_name EconomySystem
extends Node
## Calcula precios y resuelve transacciones. No conoce la UI:
## emite señales que la capa de presentación escucha.
## Responsabilidad única: reglas económicas puras.
```

## 9. Testing

- Framework: **GUT** (Godot Unit Test), en `addons/` (se añade en su fase).
- `tests/unit/` prueba Systems y utilities en aislamiento (son puros, sin UI).
- `tests/integration/` prueba flujos (venta completa, guardar/cargar).
- Regla: todo sistema en `scripts/systems|economy|crafting|inventory|events` debe
  ser testeable **sin instanciar UI**. Si no lo es, está mal acoplado.

## 10. Flujo de arranque (boot)

```
project.godot → autoloads se inicializan en orden →
GameConfig carga tuning → SaveManager detecta slots →
SceneRouter abre MainMenu → (Nueva partida) GameState.new_game() →
SceneRouter → escena Shop
```

## 11. Preguntas abiertas

- 🔴 ¿Usamos un plugin de diálogo de terceros (Dialogic) o motor propio de datos?
  Ver [Dialogue](10_Dialogue.md).
- 🔴 ¿`GameState` mantiene todo el mundo en memoria o se trocea por regiones?
  Decidir al dimensionar el guardado (Fase 8).
- 🟡 Confirmar GUT como framework de tests al llegar a la fase con lógica.
