class_name GameEnums
extends RefCounted
## Enumeraciones compartidas del juego. Sin lógica: solo tipos centralizados
## para evitar duplicar enums entre sistemas. Ver docs/systems/00_Architecture.md.

## Categoría de un objeto. Ver docs/Items.md.
enum Category { WEAPON, ARMOR, POTION, TOOL, MAGIC, MATERIAL, DECORATION }

## Rareza de un objeto. Ver docs/Items.md.
enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }

## Facciones del reino. Ver docs/WorldBible.md y docs/systems/04_Reputation.md.
enum Faction { GUILD, CROWN, ARCANE, ARTISANS, COMMONERS, PEDDLERS }
