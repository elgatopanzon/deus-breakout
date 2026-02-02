# ABOUTME: ComboTiers component — maps combo count thresholds to score multipliers
# ABOUTME: Singleton on DeusWorld; read by ScoringPipeline and ComboMultiplierPipeline

class_name ComboTiers extends DefaultComponent
@export var tiers: Dictionary = { 1: 1.0, 5: 2.0, 10: 3.0, 20: 5.0 }
