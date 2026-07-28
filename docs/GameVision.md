# Visión del juego — Dungeon Shop (resumen sin historia)

> Documento de visión aportado por el diseñador (dueño del proyecto). Es la brújula
> de alcance y prioridades. Se complementa con el [GDD](GameDesignDocument.md) y la
> [biblia de mundo](WorldBible.md). Los sistemas listados están (o estarán)
> implementados según el [Roadmap](Roadmap.md).

## Concepto
Juego indie de **simulación, gestión, RPG y sandbox** donde administras una tienda
para aventureros. No controlas al héroe: eres el **comerciante** que lo abastece.
Empiezas con una tienda pequeña y abandonada y puedes llegar a tener el
establecimiento más importante del mundo. Objetivo: **muchísimas horas** de
contenido, centradas en progresión, libertad y la satisfacción de hacer crecer un
negocio desde cero.

## Filosofía (4 principios)
1. Fácil de aprender.
2. Difícil de dominar.
3. Siempre debe existir una mejora por conseguir.
4. El jugador debe sentirse libre para jugar como quiera (no lineal).

## Géneros
Simulación · Gestión · Sandbox · RPG · Economía · Crafting · Exploración · Progresión.

## Bucle principal
```
Conseguir materiales → Fabricar → Vender → Ganar dinero → Mejorar la tienda →
Contratar empleados → Expandir → Desbloquear zonas → Materiales mejores →
Objetos más valiosos → (repetir)
```
Cada ciclo hace al jugador más eficiente y abre nuevas posibilidades.

## Sistemas (mapa a la implementación)
| Área de la visión | Sistema(s) en el proyecto |
|-------------------|---------------------------|
| Administración de la tienda | `GameState`, `Inventory`, **`ShopLayout` (vista cenital: colocar estantes y asignar qué va en cada uno)** |
| Fijar precios / economía viva | `EconomySystem`, `DemandModel`, `MarketSystem`, `EventEngine` |
| Clientes con preferencias/presupuesto/personalidad | `CustomerData`, `CustomerNeed`, `MoodComponent`, `HaggleResolver` |
| Aventureros que vuelven y traen cosas | `HeroProfile`, `ExpeditionResolver`, `HeroManager` |
| Objetos (categorías, calidad, rareza, demanda) | `ItemData`, `ItemInstance`, `ItemDatabase` |
| Crafting (recetas, estaciones, investigación) | `RecipeData`, `CraftingResolver`, `MaterialTrait`, **`ResearchSystem`** |
| Calidad influye en precio/prestigio | `QualityCalculator`, `PlayerSkills`, `ReputationSystem` |
| Empleados con roles | **`EmployeeData`, `EmployeeManager`** |
| Mejoras (todo mejorable) | `PlayerSkills`, `ProgressionSystem` (diseño), upgrades |
| Exploración / regiones | **`RegionData`, `ExplorationSystem`** |
| Eventos y "jefes" que alteran el mercado | `EventData`, `EventEffect`, `EventEngine` |
| Reputación | `ReputationSystem` |
| Decoración con efecto | **`DecorationData`** + casillas DECOR de `ShopLayout` |
| Guardado (partidas largas) | `SaveManager`, `GameState.capture/restore` |
| Misiones/logros (siempre una meta) | `QuestSystem`, `AchievementSystem` |

## Dirección visual (decisión del diseñador)
- **2D**, estilo *cozy* con identidad propia.
- La tienda se ve en **vista cenital (top-down)**: el jugador **coloca los muebles/
  estantes en una cuadrícula y elige qué producto va en cada estante**. Modelado por
  `ShopLayout`; el render top-down se aborda en la fase visual (ver [ArtDirection](ArtDirection.md)).
- Personajes con **sprites 2D animados** (`CharacterView`; hoy placeholders,
  sustituibles por arte final).

## Libertad y duración
Sandbox: el jugador decide cómo construir la tienda, qué fabricar, cómo ganar dinero
y qué mejorar primero. El objetivo no es terminar una campaña, sino **disfrutar el
proceso** de crear, mejorar y expandir un negocio que siempre ofrece una nueva meta
(objeto, mejora, empleado, receta, región).

## Futuro (post-v1.0)
Nuevas regiones/biomas, objetos, tiendas, empleados, eventos y sistemas; posible
cooperativo, clasificaciones online, expansiones y DLCs. **La base debe ser sólida y
extensible** (datos en Resources, sistemas desacoplados) para crecer durante años.
