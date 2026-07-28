# Elenco de personajes (NPCs)

> Personajes del juego: clientes recurrentes, héroes y vecinos. La **mecánica** está
> en [systems/02_Customers](systems/02_Customers.md) y
> [systems/03_Heroes](systems/03_Heroes.md); aquí se define **quiénes son**. Todos
> serán Resources (`CustomerData` / `HeroProfile`) en `resources/`. Elenco 🟡
> provisional, se cierra en Fase 2.

---

## 1. Principios de casting

- Cada recurrente tiene **una necesidad recurrente, una manía y un arco**.
- Los héroes tienen **clase, personalidad y una relación** que evoluciona con lo que
  les vendes (ver canon: "los NPCs recuerdan", [Lore](Lore.md)).
- Diversidad de personalidades y roles; humor amable, nada de estereotipos crueles.
- Nombres provisionales; se pueden cambiar en Fase 2.

## 2. Héroes (arcos de expedición) — objetivo ~6 en v1.0

| Nombre 🟡 | Clase | Rasgo | Gancho / arco |
|-----------|-------|-------|---------------|
| **Brida** | Guerrera | Impulsiva, leal | Novata que crece si la equipas bien; puede volverse tu mejor clienta |
| **Ossian** | Mago | Cauto, tacaño | Regatea duro; recompensa con recetas arcanas si ganas su confianza |
| **Perla** | Pícara | Astuta, encantadora | Trae botín raro; te mete en tratos con los Buhoneros |
| **Fray Tomás** | Clérigo | Bondadoso, olvidadizo | Depende de tus pociones; su supervivencia mide tu calidad |
| **Garrok** | Bárbaro | Ruidoso, sentimental | Rompe equipo constantemente (durabilidad); cliente de repetición |
| **La Encapuchada** | ??? | Misteriosa | Ligada al arco del antecesor / la Fractura |

Cada héroe → un `HeroProfile.tres` + `ProfessionData` de su clase.

## 3. Clientes recurrentes (no héroes) — objetivo ~14 en v1.0 🟡

Vecinos y clientela con nombre que dan vida al pueblo. Ejemplos semilla:

| Nombre 🟡 | Rol | Necesidad típica | Gancho |
|-----------|-----|------------------|--------|
| **Doña Mabel** | Herbolaria del pueblo | Vende/compra hierbas | Proveedora amiga; tutorial de materiales |
| **El Alguacil** | Autoridad local | Herramientas, orden | Puente con la Corona |
| **Cintia** | Tabernera del Ciervo Cojo | Rumores | Fuente de encargos y eventos |
| **Viejo Anselmo** | Herrero jubilado | Nostalgia, consejo | Enseña recetas/técnicas (Artesanos) |
| **Los gemelos Rus** | Aprendices traviesos | Chucherías, cachivaches | Humor, misiones menores |

(Se completa el elenco en Fase 2.)

## 4. Facciones y sus representantes

Cada facción ([Lore](Lore.md) §4, [Reputation](systems/04_Reputation.md)) tiene un
**NPC-cara** que aparece al subir afinidad (p. ej. un maestro del Gremio, un
enviado de la Corona, una archimaga del Círculo). Se definen en Fase 2.

## 5. Datos por NPC

`CustomerData` / `HeroProfile` (Resources) incluyen: id, nombre (clave i18n),
retrato(s)/emociones, categoría preferida, presupuesto/rango, personalidad
(parámetros de `MoodComponent`), diálogos asociados ([Dialogue](systems/10_Dialogue.md))
y, para héroes, clase, nivel, lealtad y arco.

## 6. Preguntas abiertas

- 🔴 Elenco definitivo y sus arcos (Fase 2).
- 🔴 Identidad de "La Encapuchada" y su relación con el antecesor (Lore).
- 🟡 Nombres finales (los actuales son placeholders).
