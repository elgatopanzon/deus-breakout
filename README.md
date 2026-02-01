# Breakout with Godot Deus

> Classic Breakout clone built entirely with the [Godot Deus](https://github.com/elgatopanzon/deus) ECS plugin - every mechanic runs through components and pipelines, no node scripts.

![Screenshot](screenshot.png)

## Quick Start

1. Clone the repo (including the Deus addon):
   ```
   git clone https://github.com/elgatopanzon/deus-breakout.git
   ```
2. Open in Godot 4.6
3. Press F5 to run

The Deus autoload is pre-configured in `project.godot`. No additional setup needed.

## About

This is a fully playable Breakout clone where paddle input, ball physics, brick damage, scoring, lives, and win/lose conditions are all implemented as Deus ECS pipelines. Scene files declare entity data via DeusConfiguration nodes. A single bootstrap script (`Main.gd`) registers pipelines with the scheduler and sets up injection chains. There are no scripts on entities or UI elements.

The project serves as a reference for building a complete game with the Deus ECS framework.

## Examples

### Component: pure data container

```gdscript
class_name Health extends DefaultComponent
@export var value: int = 1
```

Components hold data. Pipelines read and write them. `@export` makes fields editable in DeusConfiguration nodes.

### Pipeline: scheduled system

```gdscript
class_name DamagePipeline extends DefaultPipeline

static func _requires(): return [Health, Damage]

static func _stage_apply(context):
    if context.Damage.value <= 0:
        return
    context.Health.value -= context.Damage.value
    context.Damage.value = 0
```

`_requires()` declares which components an entity must have. The scheduler runs this every frame on all matching entities. Component access is via `context.<ComponentName>`.

### Pipeline injection: gate pattern

```gdscript
class_name BallMissedPipeline extends DefaultPipeline

static func _requires(): return [Position, Velocity, Size]

static func _stage_detect(context):
    var vp = context._node.get_viewport_rect().size
    var bottom_clamp = vp.y - context.Size.value.y
    if context.Position.value.y < bottom_clamp:
        context.result.cancel("ball not at bottom")
```

`context.result.cancel()` stops all injected downstream pipelines (LivesDecrementPipeline, GameOverPipeline, BallRespawnPipeline) from running. This is how Deus handles conditional execution chains.

### Declarative entity setup (Brick.tscn)

```
Brick (Area2D)
  Visual (ColorRect)
  CollisionShape2D
  DeusConfiguration
    node_id = "brick"
    components = [Health(1), Damage(0), Size(50, 20)]
    signals_to_pipelines = [area_entered -> BrickCollisionPipeline]
```

No code needed to set up an entity. DeusConfiguration attaches components in `_enter_tree()` and wires signals in `_ready()`.

### Bootstrap (Main.gd)

```gdscript
# Scheduled pipelines (run every frame)
for pipeline in [PaddleInputPipeline, MovementPipeline, PositionClampPipeline,
    BallMovementPipeline, WallReflectionPipeline, DamagePipeline,
    DestructionPipeline, BrickVisualSyncPipeline, BallMissedPipeline,
    PausePipeline, HUDSyncPipeline, OverlaySyncPipeline]:
    Deus.register_pipeline(pipeline)
    Deus.pipeline_scheduler.register_task(PipelineSchedulerDefaults.OnUpdate, pipeline)

# Scoring injects before destruction so components are still readable
Deus.inject_pipeline(ScoringPipeline, Callable(DestructionPipeline, "_stage_destroy"), true)

# Game state singletons on world node
Deus.set_component(Deus, Score, Score.new())
Deus.set_component(Deus, Lives, Lives.new())
Deus.set_component(Deus, GameState, GameState.new())
```

`Main.gd` is the only script in the project. It registers pipelines, sets up injection order, and initializes world-level state.

## Project Structure

```
classes/
  components/    # Data containers (Health, Velocity, Position, Score, Lives, ...)
  pipelines/     # Systems (DamagePipeline, BallMovementPipeline, HUDSyncPipeline, ...)
scenes/
  Main.tscn      # Root scene with Paddle, Ball, HUD as children
  Main.gd        # Bootstrap: pipeline registration and injection
  Ball.tscn      # Ball entity with DeusConfiguration
  Brick.tscn     # Brick entity template with DeusConfiguration
  Paddle.tscn    # Paddle entity with DeusConfiguration
  HUD.tscn       # UI layer with DeusConfiguration on each element
addons/deus/     # Godot Deus ECS framework
```

## Tech Stack

| Category | Technology |
|----------|-----------|
| Engine | Godot 4.6 |
| Language | GDScript |
| Framework | [Godot Deus](https://github.com/elgatopanzon/deus) ECS plugin |
| Targets | Desktop (Linux, Windows, macOS), Web (HTML5) |

## Roadmap

### Phase 1: MVP
- [x] Paddle entity
- [x] Ball entity
- [x] Brick entities
- [x] Score and lives tracking
- [x] Win/lose conditions
- [x] Basic UI

### Phase 2: Game Feel & Polish
- [ ] Visual effects and screen shake on brick destruction
- [ ] Particle effects for ball impacts and brick breaks
- [ ] Sound design (paddle hit, brick break, wall bounce, game over)
- [ ] Animations and transitions (level start, life lost, game won)
- [ ] Game feel tuning and juice

### Phase 3: Content & Levels
- [ ] Multiple brick layouts and level designs
- [ ] Level progression system
- [ ] Difficulty scaling (ball speed, brick durability, paddle size)
- [ ] Power-ups (multi-ball, wide paddle, laser, etc.)

## Completed Work

- **2026-01-31** - Basic UI
- **2026-01-31** - Win/lose conditions
- **2026-01-31** - Score and lives tracking
- **2026-01-31** - Brick entities
- **2026-01-31** - Ball entity
- **2026-01-29** - Paddle entity
