class_name EconomyConfig
extends Resource
## Parámetros de tuning económico. Única fuente de números de la economía: ningún
## sistema debe llevar constantes económicas propias (ver docs/systems/00_Architecture.md).
## Se edita como resources/config/EconomyConfig.tres. Ver docs/Economy.md.

## --- Calidad ---
## Multiplicador de precio por nivel de calidad; el índice es la calidad (0..5).
@export var quality_multipliers: PackedFloat32Array = PackedFloat32Array([0.6, 0.85, 1.0, 1.25, 1.6, 2.0])

## --- Demanda (global por categoría en v1.0) ---
@export var demand_neutral: float = 1.0
@export var demand_min: float = 0.5
@export var demand_max: float = 2.0
## Cuánto sube la demanda percibida al pedir un cliente esa categoría.
@export var demand_request_step: float = 0.05
## Cuánto baja al vender una unidad de esa categoría (saturación del mercado).
@export var demand_sale_step: float = 0.04
## Fracción del desvío respecto al neutro que se corrige cada jornada (0..1).
@export var demand_reversion_rate: float = 0.15

## --- Reputación ---
@export var reputation_mult_min: float = 0.9
@export var reputation_mult_max: float = 1.5

## --- Mercado de materiales ---
## Volatilidad semanal del precio de materiales (fracción; 0.2 = ±20%).
@export var market_weekly_volatility: float = 0.2
@export var market_price_min_mult: float = 0.5
@export var market_price_max_mult: float = 1.8

## --- Comercio / regateo por ánimo ---
## Margen sobre el precio justo que tolera un cliente de ánimo neutro.
@export var haggle_tolerance: float = 0.15

## --- Calendario ---
## Jornadas por semana (alinea con el ciclo del mundo, ver docs/WorldBible.md).
@export var days_per_week: int = 6
