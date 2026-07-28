# Dirección de audio — Dungeon Shop

> Música y sonido. El audio es clave para el pilar *cozy*: debe relajar, dar
> feedback satisfactorio y ambientar el reino. Estados: 🟡 provisional. La mecánica
> del `AudioManager` está en [systems/00_Architecture](systems/00_Architecture.md).

---

## 1. Pilar sonoro

**Calidez que invita a quedarse.** Melodías suaves, instrumentación acústica/folk
con toques de fantasía. El sonido de "vender bien", "forjar" y "monedas" debe ser
**placentero y adictivo** (refuerzo positivo del bucle).

## 2. Música (`audio/music/`) 🟡

- Loops temáticos por contexto: tienda (día tranquilo), fabricación (concentración),
  taberna (animado), mercado, menú (acogedor), momentos narrativos.
- Instrumentación: guitarra/laúd, arpa, flautas, cuerdas suaves, percusión ligera;
  un color arcano (campanas/sintes cálidos) para lo mágico.
- **Adaptativa 🟡:** la música reacciona al ritmo (más clientes → capa rítmica), sin
  volverse estresante. Nunca sube la tensión de forma agresiva.

## 3. Ambiente (`audio/ambience/`)

- Fondos por localización: chisporroteo del hogar, murmullo de taberna, mercado
  bullicioso, viento cerca de las Grietas. Dan sensación de lugar vivo.

## 4. Efectos (`audio/sfx/`)

Feedback satisfactorio para cada acción del bucle:
- **Comercio:** tintineo de monedas, campanilla de la puerta, "ka-ching" de venta.
- **Fabricación:** martillo en yunque, burbujeo del alambique, chispa de encantar.
- **UI:** clics suaves, papel al pasar página, confirmaciones cálidas.
- **NPCs:** *barks*/gruñidos cortos por personaje (no voz completa) — ver [Dialogue](systems/10_Dialogue.md).

Principio: cada acción importante tiene un sonido, ninguno molesta al repetirse.

## 5. Sistema (`AudioManager`)

- Autoload (ver [Arquitectura](systems/00_Architecture.md)): buses **Master / Música /
  Ambiente / SFX / UI** con volúmenes independientes en ajustes.
- API por señales: reproducir un sfx = emitir/llamar por id, sin acoplar quién lo
  pide. Pooling de reproductores para no crear nodos por sonido.
- Transiciones de música con *fade* al cambiar de escena/contexto.

## 6. Preguntas abiertas

- 🔴 Música original vs. librería licenciada para v1.0 (presupuesto).
- 🟡 Grado de adaptatividad musical (calibrar para que sume sin estresar).
