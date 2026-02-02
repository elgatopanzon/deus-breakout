# ABOUTME: Pure data class representing a brick layout grid
# ABOUTME: Data contract between BrickLayoutGenerator and SpawnBricksPipeline

class_name BrickLayout

var grid_cols: int
var grid_rows: int
var cells: Array # Array of { "col": int, "row": int, "health": int }
