# Dirección de arte — Dungeon Shop

> Identidad visual **canónica** (definida por el diseñador). Referencias tonales:
> **Moonlighter, Stardew Valley, Core Keeper** — inspiración, NUNCA copia. Objetivo:
> que una sola captura de pantalla se reconozca como Dungeon Shop. La tienda es la
> **protagonista visual**. Estado: 🟢 dirección fijada · 🟡 detalle a producir.

---

## 1. Estilo 🟢

- **Pixel art 2D HD**, alta calidad, mucho detalle, **limpio y fácil de leer**.
- **Cámara fija cenital (top-down)**, como Moonlighter/Core Keeper.
- **Nada realista ni 3D.**
- **Animaciones fluidas y suaves.**
- Paleta de **colores vivos, cálidos y agradables**.
- **Iluminación dinámica** para crear ambiente.
- Personajes **pequeños pero expresivos**, reconocibles de un vistazo.

## 2. Identidad propia (no parecer un clon) 🟢

- **Motivo "yunque + grieta arcana":** lo artesanal (yunque, fragua, madera cálida)
  combinado con un acento arcano frío (turquesa/violáceo) reservado a lo mágico y a
  la Fractura. Presente en logo, UI, iconografía y efectos.
- **La tienda como escenario vivo y cambiante** (ver §4) es el sello: el jugador ve
  crecer su negocio en pantalla.
- Estilo de personajes propio: siluetas cálidas y expresivas, gestuales.

## 3. Mundo vivo 🟢 (sistemas técnicos que lo sostienen)

El mundo debe sentirse vivo **sin perder claridad**. Sistemas (implementados como
lógica; el arte se les "pone encima"):

| Elemento | Sistema / técnica |
|----------|-------------------|
| **Ciclo día/noche** | `WorldClock` → color de `CanvasModulate` (luz ambiente) |
| **Clima** (lluvia, tormenta, nieve, niebla) | `WeatherSystem` → partículas + overlays |
| **Estaciones del año** | `WeatherSystem.season` (afecta paleta, clima y eventos) |
| **Iluminación dinámica** | `CanvasModulate` + `PointLight2D` en focos (antorchas, forja) |
| **Partículas ambientales** | `CPUParticles2D`/`GPUParticles2D`: polvo, hojas, chispas, humo, nieve, lluvia |

Regla: la ambientación **nunca** debe reducir la legibilidad del juego.

## 4. La tienda evoluciona visualmente 🟢

La apariencia cambia con la progresión (rango de tienda, ver [Progression](Progression.md)):

- **Inicio:** pequeña, vieja, oscura, desgastada, muebles rotos, poco espacio.
- **Con cada mejora:** se siente **realmente distinta**; el jugador nota que crece.
- **Final:** enorme, elegante y llena de vida.

Técnicamente: el rango de tienda selecciona **set de tiles, iluminación y decoración**
del render top-down (hook previsto en `ShopLayout` + rango). Se colocan muebles y se
**asigna qué producto va en cada estante** (la cuadrícula de `ShopLayout`).

## 5. Objetos 🟢

- **Cada objeto con sprite único.** Nada de meros cambios de color entre armas.
- Armas, armaduras, herramientas y accesorios **claramente diferenciados** entre sí.
- Los **objetos legendarios destacan** visualmente (brillo, marco, partículas).

## 6. Personajes / NPCs 🟢

- Cada NPC con **personalidad visual** y diseño **fácil de reconocer**.
- Los aventureros **reflejan su profesión** por ropa, armas y accesorios.
- Base técnica actual: `CharacterView` (sprite + animaciones por código); el arte
  final sustituye texturas/animaciones.

## 7. Interfaz 🟢

- **Minimalista, moderna y cómoda.** Ocupa **poco** espacio en pantalla.
- La información importante se entiende **rápido**. **Nada recargado.**
- (La UI actual por paneles es funcional/placeholder; se rediseñará bajo estos
  principios en el pase de arte de UI.)

## 8. Micro-animaciones ("vida") 🟢

Muchas animaciones pequeñas que hagan sentir vivo el juego. Objetivo de producción:
clientes mirando productos · empleados trabajando · humo de la forja · chispas al
fabricar · monedas al vender · lluvia en el techo · hojas al viento · antorchas con
fuego animado · animales paseando por el pueblo.

## 9. Paleta base (placeholder 🟡)

| Uso | Color placeholder |
|-----|-------------------|
| Madera / suelo cálido | ocres y marrones (#7a4a24, #8c6b46) |
| Crema / papel / UI | crema hueso (#f4e7d2) |
| Acento marca | ámbar/dorado (#e8b06a) |
| Acento arcano (magia/Fractura) | turquesa (#4fd0c8) |
| Noche | azul profundo (#2a2f55) |
| Alerta | terracota apagado (#d98f6a) |

Los valores finales se fijan al empezar la producción de arte y se guardan como
paleta/tema en `resources/config/`.

## 10. Organización de assets

`assets/sprites|tilesets|ui|icons|animations|portraits|items|characters|buildings|effects|particles|fonts`
(ver [systems/00_Architecture](systems/00_Architecture.md#estructura-de-carpetas)).
El tamaño de tile/sprite se fija al arrancar la producción de arte.

## 11. Estado de implementación técnica (fase visual)

- [x] Vista cenital (top-down) de la tienda renderizada desde `ShopLayout` (placeholders).
- [x] `WorldClock` (día/noche) y `WeatherSystem` (clima + estaciones) — lógica + tests.
- [x] Partículas ambientales y de clima (polvo, lluvia, nieve) por código.
- [ ] Tiles/sprites de pixel art HD finales (los coloca un artista; se sustituyen los placeholders).
- [ ] Iluminación con `PointLight2D` en focos; sets de tiles por rango de tienda.
- [ ] Rediseño de UI minimalista.

## 12. Preguntas abiertas

- 🟡 Tamaño base de tile/sprite y resolución objetivo (define pipeline y contrataciones).
- 🟡 ¿Asset pack inicial vs. arte a medida desde el principio? (presupuesto).
