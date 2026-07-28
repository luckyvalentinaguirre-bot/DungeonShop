# Dirección de arte — Dungeon Shop

> Identidad visual del juego. Referencias tonales: **Moonlighter, Potion Craft,
> Stardew Valley, Dave the Diver** — inspiración, **no** copia. Dungeon Shop debe
> tener **identidad propia**. Estados: 🟡 provisional hasta producción de arte.

---

## 1. Pilar visual

**Cozy artesanal.** Cálido, hecho a mano, acogedor. La tienda debe dar ganas de
quedarse: luz de vela, madera, metal pulido, frascos que brillan. La dureza de la
mazmorra se insinúa desde fuera (las Grietas), nunca invade el tono del local.

## 2. Estilo elegido 🟡

- **2D con pixel-art de resolución media** o **2D pintado** — decisión abierta (🔴),
  pero comprometidos con **2D cálido y legible**, no realista ni 3D.
- Silueta clara y lectura inmediata de objetos (el jugador identifica una poción de
  un vistazo — importante para un juego de gestión).
- Animación con *squash & stretch* suave y micro-animaciones (*juice* cozy: monedas
  que saltan, humo del alambique, brillo al vender).

## 3. Identidad propia (cómo NO parecer un clon)

- **Motivo de "yunque y grieta":** el logo/tema visual combina lo artesanal (yunque)
  con lo arcano (grieta luminosa). Presente en UI, iconografía y transiciones.
- **Paleta cálida con acentos arcanos:** base de maderas/ocres/cremas + un acento
  frío mágico (turquesa/violáceo) reservado para lo mágico y la Fractura.
- **Personajes expresivos por retrato** (estilo propio de caras redondeadas y
  gestuales), distinto de las referencias.

## 4. Paleta base (placeholder 🟡)

| Uso | Color (placeholder) |
|-----|---------------------|
| Fondo cálido / madera | ocres y marrones suaves |
| Cremas / papel / UI | crema hueso |
| Acento principal (marca) | ámbar/dorado |
| Acento arcano (magia/Fractura) | turquesa/violeta frío |
| Negativo/alerta | rojo terracota apagado |

Los valores exactos (hex) se fijan al empezar producción de arte; se guardarán como
`Theme`/paleta en `resources/config/` para consistencia.

## 5. UI / diegético

- UI **cálida y con textura de papel/madera**, esquinas redondeadas, iconografía
  dibujada a mano. Evitar UI plana y fría.
- Preferir elementos **diegéticos** donde sea posible (el libro de cuentas, la
  pizarra de encargos) para reforzar la inmersión *cozy*.
- Tipografía: una serif/humanista cálida para títulos + una legible para cuerpo
  (definir en `assets/fonts/`). Priorizar legibilidad y tamaños accesibles.

## 6. Organización de assets

Ver [systems/00_Architecture](systems/00_Architecture.md#estructura-de-carpetas):
`assets/sprites|tilesets|ui|icons|animations|portraits|items|characters|buildings|effects|particles|fonts`.
Convención de nombres y tamaños de sprite se documentará al empezar producción.

## 7. Preguntas abiertas

- 🔴 Pixel-art vs. 2D pintado (define el pipeline de arte y contrataciones).
- 🔴 Resolución base y tamaño de tile/sprite.
- 🟡 Paleta final (hex) y tipografías.
