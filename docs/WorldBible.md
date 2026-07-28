# Biblia de mundo — Dungeon Shop

> Documento maestro del mundo de **Válderin** (Fase 2). Reúne geografía, historia,
> facciones, cultura, calendario y la estructura del arco narrativo opcional. Es la
> fuente de verdad para escribir contenido coherente (diálogos, eventos, misiones,
> NPCs). Complementa [Lore.md](Lore.md) (resumen) y alimenta los sistemas.
> Estados: 🟢 canon · 🟡 provisional · 🔴 abierto.

---

## 1. Concepto del mundo 🟢

Válderin es un reino de fantasía **cálida y artesanal** cuya economía gira en torno
a las mazmorras nacidas de **la Fractura**. No es un mundo en guerra ni al borde del
apocalipsis: es un reino que ha **domesticado el peligro** y ha construido gremios,
mercados y burocracia a su alrededor. El terror de las profundidades existe, pero se
vive desde la superficie como oficio, comercio y rutina. Ese contraste —lo cotidiano
sobre lo abismal— es la identidad del mundo.

## 2. Historia del mundo (línea de tiempo) 🟢

Fechas en **AF** (Antes de la Fractura) y **DF** (Después de la Fractura). El
presente del juego es **~300 DF** 🟡.

| Época | Suceso |
|-------|--------|
| **Antigüedad (AF)** | Reinos dispersos; la magia es libre y peligrosa, poco entendida. |
| **Año 0 — La Fractura** | Una catástrofe mágica (causa disputada) resquebraja el subsuelo. Se abren las **Grietas**: pozos hacia ruinas, criaturas y magia inestable. |
| **1–50 DF — El Repliegue** | Pánico y saqueo caótico. Muchos mueren bajando sin ley. |
| **~60 DF — El Edicto de las Licencias** | La primera Corona de Válderin **regula** las Grietas: nace el **Gremio de Aventureros** y las licencias. El caos se vuelve economía. |
| **60–200 DF — La Edad de los Gremios** | Florecen Gremio, Círculo Arcano y Liga de Artesanos. Se funda la capital sobre la mayor Grieta. |
| **~150 DF — Fundación de Rincón de Yunque** | La familia **Yunque** levanta una fragua-tienda junto a una Grieta menor; el caserío toma su nombre. |
| **~300 DF — Presente** | Reino estable y burocrático. Tu abuela **Rilda Yunque** desapareció en las Grietas hace poco. Heredas la tienda. |

**Nota de diseño:** la causa exacta de la Fractura es **deliberadamente ambigua** y
es el corazón del misterio opcional (ver §8). No revelarla en material de mundo.

## 3. Geografía y mapa del reino 🟢

Válderin es una comarca de valles y colinas. El jugador no viaja a pie por un mundo
abierto: **navega entre localizaciones** desde el mapa del reino (escena `kingdom/`).

```
                 [ LAS GRIETAS ]  (frontera - no se baja)
                        |
   [ BARRIO ARCANO ] — [ CAPITAL: VÁLDERIN ] — [ LA CORONA / GREMIOS ]
                        |
                 [ EL MERCADO BAJO ]
                        |
   [ TABERNA DEL CIERVO COJO ] — [ RINCÓN DE YUNQUE: TU TIENDA ]  ← inicio
```

### 3.1 Localizaciones (atmósfera y función)

| Lugar | Atmósfera | Función jugable | Facción dominante |
|-------|-----------|-----------------|-------------------|
| **Rincón de Yunque** | Pueblo cálido, humo de fragua, luz de vela | Base: tienda, fabricación, almacén, decoración | Pueblo llano / Artesanos |
| **La Taberna del Ciervo Cojo** | Bulliciosa, madera, canciones | Rumores, encargos, conocer héroes, contratar | Gremio de Aventureros |
| **El Mercado Bajo** | Callejuelas, puestos, regateo | Comprar materiales, proveedores, tratos grises | Buhoneros / Artesanos |
| **La Capital (Válderin)** | Piedra noble, banderas, burocracia | Contratos de Corona, clientela de élite, permisos | La Corona |
| **Barrio Arcano** | Torres, luz turquesa, silencio | Materiales mágicos, recetas raras, encantar | Círculo Arcano |
| **Las Grietas** | Niebla fría, borde del abismo | Ver partir/volver héroes; umbral del misterio | — (neutral/peligro) |

### 3.2 Orden de desbloqueo 🟡

Ligado a rango de tienda y reputación (ver [Progression](Progression.md)):

1. **Inicio:** Rincón de Yunque (tienda) + Las Grietas (visible, narrativo).
2. **Bronce:** El Mercado Bajo (comprar materiales) + Taberna (héroes/encargos).
3. **Plata:** La Capital (facción Corona, clientela élite).
4. **Oro:** Barrio Arcano (magia, recetas raras).
5. **Legendaria:** acceso pleno + tramos finales del arco de la abuela.

## 4. Facciones (detalle) 🟢

Cada facción tiene **identidad, qué te pide y qué te da**. La afinidad se gana
sirviéndolas bien (ver [Reputation](systems/04_Reputation.md)).

### 4.1 Gremio de Aventureros
- **Identidad:** héroes con licencia; pragmáticos, camaradería ruda.
- **Te piden:** equipar bien a sus miembros, encargos de expedición, fiabilidad.
- **Te dan:** héroes de élite, encargos lucrativos, botín raro de mazmorra.
- **Cara pública:** un maestro de gremio veterano (definir NPC en [NPCs](NPCs.md)).

### 4.2 La Corona
- **Identidad:** autoridad, ejército, orden y burocracia. Formales, exigentes.
- **Te piden:** contratos grandes a plazo, calidad garantizada, impuestos al día.
- **Te dan:** contratos enormes, permisos de expansión de barrio, prestigio oficial.

### 4.3 Círculo Arcano
- **Identidad:** magos y alquimistas; curiosos, herméticos, algo altivos.
- **Te piden:** materiales puros, discreción, experimentar con lo arcano.
- **Te dan:** recetas mágicas, materiales raros, encantamientos, pistas de la Fractura.

### 4.4 Liga de Artesanos
- **Identidad:** herreros y gremios de oficio; orgullo del trabajo bien hecho.
- **Te piden:** honrar el oficio, calidad sin defectos, aprender técnicas.
- **Te dan:** estaciones de fabricación, técnicas, mejoras. **Aliada natural de la
  familia Yunque** (la abuela era una leyenda para ellos).

### 4.5 Pueblo llano
- **Identidad:** vecinos, aldeanos, clientela común. Cálidos, chismosos, leales.
- **Te piden:** precios justos, buen trato, formar parte de la comunidad.
- **Te dan:** lealtad de base, propinas, eventos comunitarios, buena fama.

### 4.6 Los Buhoneros
- **Identidad:** mercaderes grises y contrabandistas; simpáticos pero turbios.
- **Te piden:** discreción, tolerancia al riesgo, no preguntar de más.
- **Te dan:** materiales exóticos difíciles de conseguir, a mejor precio pero con riesgo.

## 5. Tensiones entre facciones 🟢

**Decisión de Fase 2** (cierra el 🔴 de [Reputation](systems/04_Reputation.md)):
ganar mucho con una facción puede irritar a su rival. No obliga a elegir bando, pero
crea estrategia. Magnitud del roce: **suave** (subir A resta un poco a B), nunca
bloqueante.

| Par enfrentado | Motivo del roce | Efecto de diseño |
|----------------|-----------------|------------------|
| **La Corona ⚔ Los Buhoneros** | Ley vs. contrabando | Subir con una baja levemente la otra. Eje "legalidad". |
| **Círculo Arcano ⚔ La Corona** | Magia libre vs. control estatal | Roce suave; la Corona desconfía de lo arcano. |
| **Gremio ⚔ Liga de Artesanos** | Quién manda: quien usa el equipo o quien lo hace | Rivalidad amistosa; ligero tira y afloja. |

**Neutrales / compatibles:** el **Pueblo llano** no está enfrentado con nadie (subir
con todos ayuda con el pueblo). El **Gremio y el Círculo** conviven sin roce directo.

## 6. Cultura y vida cotidiana 🟢

Material de ambientación para diálogos, eventos y *flavor*:

- **La superficie vive del abismo.** Es normal desayunar mientras pasan aventureros
  camino de las Grietas. La muerte en mazmorra se lamenta pero no escandaliza.
- **Los tenderos y artesanos gozan de respeto:** equipar héroes es un oficio noble.
  Tu apellido, Yunque, abre puertas y también expectativas.
- **Supersticiones:** tocar el yunque antes de una expedición da suerte; nunca
  vender un arma "sin nombre" a un héroe novato; las pociones se agitan tres veces.
- **Ocio:** ferias estacionales, canciones de taberna sobre héroes caídos, apuestas
  sobre quién vuelve de las Grietas.

## 7. Calendario y tiempo del mundo 🟡

Alinea el ciclo temporal del juego (ver [GDD](GameDesignDocument.md) §7) con el mundo:

- La unidad es la **jornada**; **6 jornadas = una semana** 🟡 (ciclo de mercado y
  eventos).
- **Cuatro estaciones** temáticas, cada una con su feria/festival (ganchos de
  [Events](systems/07_Events.md)): Siembra, Sol Alto, Cosecha, Escarcha.
- Festividades del reino (placeholders 🟡): **Feria de la Fragua** (Artesanos),
  **Día de las Licencias** (Gremio/Corona), **Noche Arcana** (Círculo).

## 8. El misterio opcional: el arco de la abuela 🟡

Estructura del **hilo narrativo opcional** (sandbox-friendly). Se entrega en
**capítulos ligeros** desbloqueados por hitos naturales, nunca bloquea el juego.

- **Gancho:** el cuaderno inacabado de la abuela Rilda, con recetas a medias y notas
  crípticas sobre la Fractura.
- **Progresión:** cada tramo desbloquea páginas del cuaderno → recetas nuevas
  (recompensa tangible) + un fragmento de la historia de la abuela.
- **Motor:** pistas llegan por rumores de héroes, eventos, y afinidad con el Círculo
  Arcano (que sabía de sus investigaciones).
- **Clímax (opcional):** el jugador descubre **qué buscaba la abuela en la Fractura**
  y toma una decisión que da un **epílogo** narrativo, sin alterar el sandbox.
- 🔴 **Reservado:** la revelación exacta (qué es la Fractura / destino de la abuela)
  se dosifica y cierra al escribir los capítulos (Fase 7/9). Mantener ambiguo hasta
  entonces. Principios: nada que rompa el tono cozy; la abuela no "murió en vano";
  el jugador siente que **honra su legado**, no que hereda una tragedia.

## 9. Glosario del mundo 🟢

- **La Fractura:** catástrofe mágica del Año 0 que abrió las Grietas.
- **Las Grietas:** pozos-mazmorra hacia las profundidades. Frontera jugable.
- **Válderin:** el reino y su capital homónima.
- **Rincón de Yunque:** el pueblo del jugador; hogar de la familia Yunque.
- **Los Yunque:** tu familia de artesanos-tenderos. Abuela: **Rilda Yunque**.
- **Coronas / cobres:** moneda (100 cobres = 1 corona).
- **Licencia:** permiso de la Corona para bajar a las Grietas como aventurero.
- **AF / DF:** Antes / Después de la Fractura (cómputo del calendario).

## 10. Preguntas abiertas

- 🔴 La revelación del misterio de la Fractura y el destino final de la abuela (§8) —
  cerrar al escribir el arco (Fase 7/9).
- 🟡 Nombres de las caras públicas de cada facción (se fijan al cerrar [NPCs](NPCs.md)).
- 🟡 Año exacto del presente y detalle de festividades/estaciones.
