# Breakable Interactables System

## Overview
Breakable interactables are objects that respond to player attacks instead of proximity. When attacked, they can drop items, apply effects to the player, or both.

## How It Works
- Extends the existing `Collectable` base class for consistency
- Uses a `HurtBox` to detect player attacks (same system used by enemies)
- Supports configurable drop chances and multiple effects
- Includes break animations and visual feedback

## Key Components

### BreakableInteractable (Base Class)
- **collectableAsItem**: Item to potentially drop when broken
- **drop_chance**: Probability (0.0-1.0) of dropping the item
- **effects**: Array of `InteractableEffect` resources to apply when broken
- **break_animation_name**: Animation to play when breaking (default: "break")

### InteractableEffect (Base Class)
Base class for creating custom effects. Built-in effects include:
- **HealingEffect**: Restores player health
- **DamageEffect**: Deals damage to player

### Example Scenes
- **breakable_pot.tscn**: Drops items when attacked (80% chance)
- **explosive_trap.tscn**: Damages player when attacked, no item drop
- **test_breakables.tscn**: Demo scene showing different types

## Usage

### Creating a Basic Breakable
1. Instance `breakable_interactable.tscn`
2. Set the `collectableAsItem` to desired drop item
3. Adjust `drop_chance` (1.0 = always drops, 0.0 = never drops)
4. Optionally add effects to the `effects` array

### Creating Custom Effects
1. Create a new script extending `InteractableEffect`
2. Override the `apply_effect()` method
3. Create a `.tres` resource file for the effect
4. Add the effect resource to a breakable's `effects` array

### Example Custom Effect
```gdscript
class_name SpeedBoostEffect extends InteractableEffect

@export var speed_boost: float = 200.0
@export var duration: float = 5.0

func apply_effect() -> void:
    # Implement speed boost logic
    print("Player speed boosted!")
```

## Integration
The system integrates seamlessly with existing game systems:
- Uses the same collision layers as enemy combat
- Works with the existing inventory system
- Follows the same item dropping patterns as other collectables
- Uses PlayerManager for health/stats modifications

## Testing
Load `test_breakables.tscn` to see examples of different breakable types. Attack them with your sword to see the different behaviors! 