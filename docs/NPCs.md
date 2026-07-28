# Elenco de personajes (NPCs)

> Personajes del juego: la abuela, héroes, clientes recurrentes y caras de facción.
> La **mecánica** está en [systems/02_Customers](systems/02_Customers.md) y
> [systems/03_Heroes](systems/03_Heroes.md); aquí se define **quiénes son y sus
> arcos**. Todos serán Resources (`CustomerData` / `HeroProfile`) en `resources/`.
> **Reparto cerrado en Fase 2** (🟢 canon de casting; los nombres son firmes salvo
> retoques menores). Ambientación en [WorldBible](WorldBible.md).

---

## 1. Principios de casting 🟢

- Cada recurrente tiene **una necesidad recurrente, una manía y un arco**.
- Los héroes tienen **clase, personalidad y una relación** que evoluciona con lo que
  les vendes (canon: "los NPCs recuerdan", [Lore](Lore.md)).
- Diversidad de personalidades y roles; humor amable, nada de estereotipos crueles.
- Todo personaje se ancla al mundo: familia Yunque, facciones y localizaciones.

## 2. La abuela — Rilda Yunque 🟢 (personaje ausente, motor narrativo)

No aparece "viva" en escena (desapareció en las Grietas), pero **está presente en
todo**: su cuaderno, sus dichos citados por otros, su retrato en la tienda, su
reputación entre los Artesanos y el Gremio. Es la brújula del arco opcional
(ver [WorldBible](WorldBible.md#8-el-misterio-opcional-el-arco-de-la-abuela)).
Los NPCs la recuerdan y te miden contra ella ("la vieja Rilda esto lo hacía así…").

## 3. Héroes (arcos de expedición) — 6 en v1.0 🟢

Cada uno → un `HeroProfile.tres` + `ProfessionData` de su clase.

| Nombre | Clase | Rasgo | Arco (relación con tu tienda) |
|--------|-------|-------|-------------------------------|
| **Brida** | Guerrera | Impulsiva, leal | Novata que crece si la equipas bien; puede volverse tu mejor clienta y una voz del Gremio a tu favor. |
| **Ossian** | Mago | Cauto, tacaño | Regatea duro; si ganas su confianza te abre el Círculo Arcano y recetas mágicas. |
| **Perla** | Pícara | Astuta, encantadora | Trae botín raro; te introduce en los tratos de los Buhoneros (y sus riesgos). |
| **Fray Tomás** | Clérigo | Bondadoso, olvidadizo | Depende de tus pociones; su supervivencia es el termómetro de tu calidad. Ligado al Pueblo llano. |
| **Garrok** | Bárbaro | Ruidoso, sentimental | Rompe equipo sin parar (durabilidad); cliente de repetición y alivio cómico con corazón. |
| **La Encapuchada** | Errante (clase velada) | Misteriosa | **Ligada al arco de la abuela:** conoció a Rilda y aparece cuando avanzas el cuaderno. Su identidad es parte del misterio opcional. |

## 4. Clientes recurrentes (no héroes) — 14 en v1.0 🟢

Vecinos y clientela con nombre que dan vida al pueblo y sirven de puentes a las
facciones. Núcleo inicial (los restantes se detallan al construir contenido):

| Nombre | Rol | Necesidad típica | Manía / gancho |
|--------|-----|------------------|----------------|
| **Doña Mabel** | Herbolaria del pueblo | Vende/compra hierbas | Tutorial de materiales; proveedora amiga; Pueblo llano. |
| **El alguacil Cobos** | Autoridad local | Herramientas, orden | Habla en refranes; puente hacia la Corona. |
| **Cintia** | Tabernera del Ciervo Cojo | Rumores, pedidos de la casa | Sabe todo del pueblo; fuente de encargos y eventos. |
| **Viejo Anselmo** | Herrero jubilado | Nostalgia, consejo | Fue rival cariñoso de tu abuela; enseña técnicas (Artesanos). |
| **Los gemelos Rus** | Aprendices traviesos | Chucherías, cachivaches | Rompen cosas; humor y misiones menores. |
| **Sor Beltrana** | Sanadora | Pociones a granel | Compra en lote para los heridos; presiona por calidad. |
| **Nael el correo** | Mensajero del reino | Herramientas de viaje | Trae noticias y encargos de fuera. |
| **La señora Ordás** | Terrateniente tacaña | Lujo, ostentación | Regatea sin piedad; recompensa el trato fino. |

## 5. Caras de facción 🟢

Cada facción tiene un NPC-cara que aparece al subir afinidad
(ver [Reputation](systems/04_Reputation.md), [WorldBible](WorldBible.md#4-facciones-detalle)):

| Facción | Cara pública | Nota |
|---------|--------------|------|
| **Gremio de Aventureros** | **Maestre Dorn**, veterano tuerto | Da encargos de expedición y héroes de élite. |
| **La Corona** | **Intendente Valquira**, funcionaria estricta | Contratos grandes y permisos de expansión. |
| **Círculo Arcano** | **Archimaga Sombralís** | Recetas mágicas y pistas de la Fractura. |
| **Liga de Artesanos** | **Maestra Gremial Yuste** | Estaciones y técnicas; admiraba a tu abuela. |
| **Pueblo llano** | *(colectivo)* Doña Mabel / Cintia | El pueblo se expresa por sus vecinos. |
| **Los Buhoneros** | **Cándido "Manosveloces"** | Materiales exóticos a riesgo; simpático y turbio. |

## 6. Datos por NPC 🟢

`CustomerData` / `HeroProfile` (Resources) incluyen: id, nombre (clave i18n),
retrato(s)/emociones, categoría preferida, presupuesto/rango, personalidad
(parámetros de `MoodComponent`), facción asociada, diálogos
([Dialogue](systems/10_Dialogue.md)) y, para héroes, clase, nivel, lealtad y arco.

## 7. Preguntas abiertas

- 🟢 *(cerrada en Fase 2)* Reparto principal, caras de facción e identidad narrativa
  de La Encapuchada (ligada a la abuela; velo se resuelve en el arco).
- 🟡 Los 6 clientes recurrentes restantes (hasta 14) se detallan al escribir contenido.
- 🟡 Nombres finales — firmes salvo retoques de sonoridad en localización.
