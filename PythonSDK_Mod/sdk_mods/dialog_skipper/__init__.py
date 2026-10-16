# ==============================================================================
# Tiny Tina's Wonderlands - Dialog Skipper (Python SDK Version)
# ==============================================================================
# Compatible with: Oak Mod Manager (bl-sdk) for Borderlands 3 & Tiny Tina's Wonderlands
# Features:
#   - Keybind to skip active dialogue instantly (defaults to F6 via SDK settings)
#   - Auto Skip toggle option in the in-game Mod Menu
#   - Fast Forward toggle & hold keybinds for animation-stalled quests
# ==============================================================================

# ruff: noqa: D103
if True:
    assert __import__("mods_base").__version_info__ >= (1, 0), "Please update the SDK"

from typing import Any

import unrealsdk
from mods_base import ENGINE, BoolOption, EInputEvent, build_mod, hook, keybind
from unrealsdk.hooks import Block, Type

__version__: str
__version_info__: tuple[int, ...]


@keybind("Skip Dialog")
def skip_dialog() -> None:
    """Instantly stops active dialogue thread on all loaded GbxDialogComponents."""
    for dialog in unrealsdk.find_all("GbxDialogComponent", exact=False):
        thread_id = dialog.CurrentPerformance.DialogThreadID
        if thread_id > 0:
            dialog.StopPerformance(thread_id, True)


auto_skip = BoolOption(
    "Auto Skip",
    False,
    description=(
        "Automatically skip all dialogue as soon as it is started. This includes ALL dialogue, "
        "including idle chatter and combat taunts, so disable this if you only want manual skipping."
    ),
)


@hook("/Script/GbxDialog.GbxDialogComponent:StartPerformance", Type.PRE)
def dialog_start_performance(*_: Any) -> type[Block] | None:
    """Interception hook to auto-block dialogue if Auto Skip is enabled."""
    return Block if auto_skip.value else None


# Fast-Forward Feature (Global Time Dilation)
gameplay_statics = unrealsdk.find_class("GameplayStatics").ClassDefaultObject
set_time_dialation = gameplay_statics.SetGlobalTimeDilation
get_time_dialoation = gameplay_statics.GetGlobalTimeDilation

FAST_FORWARD_SPEED = 5.0


@keybind("Fast Forward (Toggle)")
def fast_forward_toggle() -> None:
    """Toggle between normal game speed and 5x fast forward."""
    world = ENGINE.GameViewport.World
    current_dialation = get_time_dialoation(world)
    new_dialation = FAST_FORWARD_SPEED if current_dialation == 1 else 1.0
    set_time_dialation(world, new_dialation)


@keybind("Fast Forward (Hold)", event_filter=None)
def fast_forward_hold(event: EInputEvent) -> None:
    """Hold key down for temporary 5x fast forward, release to return to 1x."""
    dialation: float
    match event:
        case EInputEvent.IE_Pressed:
            dialation = FAST_FORWARD_SPEED
        case EInputEvent.IE_Released:
            dialation = 1.0
        case _:
            return

    set_time_dialation(ENGINE.GameViewport.World, dialation)


build_mod()
