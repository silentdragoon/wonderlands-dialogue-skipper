-- ==============================================================================
-- Tiny Tina's Wonderlands - Dialogue Skipper Mod (Modernized)
-- ==============================================================================
-- Compatible with: RE-UE4SS v2.5.2+, v3.0+, and legacy UE4SS versions.
-- Default Hotkeys:
--   [F6] : Skip currently playing dialogue lines immediately.
--   [F7] : Toggle Fast-Forward (5x game speed) for unskippable walking/cutscene animations.
-- ==============================================================================

local CONFIG = {
    -- Key to instantly stop and skip currently playing dialogue.
    -- Common alternatives: Key.F1, Key.F5, Key.F6, Key.F8, Key.X, Key.Z
    SkipKey = Key.F6,

    -- Key to toggle fast-forward time dilation (speeds up physical NPC walking animations)
    FastForwardKey = Key.F7,

    -- Multiplier for Fast-Forward (e.g., 5.0 = 5x normal speed)
    FastForwardSpeed = 5.0,

    -- Enable or disable the Fast-Forward feature
    EnableFastForward = true,

    -- Print skip actions and status to the UE4SS console / log
    LogToConsole = true
}

-- Internal state tracking
local isFastForwardActive = false

-- ------------------------------------------------------------------------------
-- Helper: Safe Thread Execution
-- Modern RE-UE4SS requires UObject interactions to take place on the game thread.
-- ------------------------------------------------------------------------------
local function SafeExecuteInGameThread(fn)
    if type(ExecuteInGameThread) == "function" then
        ExecuteInGameThread(function()
            local ok, err = pcall(fn)
            if not ok and CONFIG.LogToConsole then
                print("[DialogSkipper Error] " .. tostring(err))
            end
        end)
    else
        local ok, err = pcall(fn)
        if not ok and CONFIG.LogToConsole then
            print("[DialogSkipper Error] " .. tostring(err))
        end
    end
end

-- ------------------------------------------------------------------------------
-- Helper: Universal Keybind Registration
-- Different versions of UE4SS use either 2 or 3 parameters for RegisterKeyBind.
-- ------------------------------------------------------------------------------
local function SafeRegisterKeyBind(key, callback)
    if not key then
        print("[DialogSkipper] Warning: Keybind is nil or invalid.")
        return
    end

    -- Attempt 3-argument overload first: RegisterKeyBind(key, modifiers_table, callback)
    local success = pcall(function()
        RegisterKeyBind(key, {}, callback)
    end)

    -- Fallback to 2-argument overload: RegisterKeyBind(key, callback)
    if not success then
        success = pcall(function()
            RegisterKeyBind(key, callback)
        end)
    end

    if not success and CONFIG.LogToConsole then
        print("[DialogSkipper] Failed to register keybind for key: " .. tostring(key))
    end
end

-- ------------------------------------------------------------------------------
-- Core Function: Skip Dialogue
-- Finds active GbxDialogComponent instances and halts the active performance thread.
-- ------------------------------------------------------------------------------
local function SkipActiveDialogue()
    SafeExecuteInGameThread(function()
        local skippedCount = 0
        local classesToInspect = { "GbxDialogComponent", "OakDialogComponent" }

        for _, className in ipairs(classesToInspect) do
            local components = FindAllOf(className)
            if components then
                for _, dialogComp in ipairs(components) do
                    if dialogComp and dialogComp:IsValid() then
                        -- Check CurrentPerformance struct for active dialogue thread ID
                        local currentPerf = dialogComp.CurrentPerformance
                        if currentPerf then
                            local threadId = currentPerf.DialogThreadID
                            if threadId and threadId > 0 then
                                -- StopPerformance(int32 ThreadID, bool bCompleteSuccessfully)
                                -- Passing true tells the game narrative script the line finished properly.
                                local callOk = pcall(function()
                                    dialogComp:StopPerformance(threadId, true)
                                end)

                                if callOk then
                                    skippedCount = skippedCount + 1
                                end
                            end
                        end
                    end
                end
            end
        end

        if CONFIG.LogToConsole then
            if skippedCount > 0 then
                print(string.format("[DialogSkipper] Skipped %d active dialogue thread(s).", skippedCount))
            else
                print("[DialogSkipper] F6 pressed: No active dialogue was playing.")
            end
        end
    end)
end

-- ------------------------------------------------------------------------------
-- Core Function: Fast Forward Toggle
-- Speeds up world time dilation to fast-forward slow walking NPCs or door animations.
-- ------------------------------------------------------------------------------
local function ToggleFastForward()
    if not CONFIG.EnableFastForward then return end

    SafeExecuteInGameThread(function()
        if not isFastForwardActive then
            isFastForwardActive = true
            local speedCmd = string.format("slomo %0.1f", CONFIG.FastForwardSpeed)
            ExecuteConsoleCommand(speedCmd)
            if CONFIG.LogToConsole then
                print(string.format("[DialogSkipper] Fast-Forward ENABLED (%0.1fx speed).", CONFIG.FastForwardSpeed))
            end
        else
            isFastForwardActive = false
            ExecuteConsoleCommand("slomo 1.0")
            if CONFIG.LogToConsole then
                print("[DialogSkipper] Fast-Forward DISABLED (1.0x normal speed).")
            end
        end
    end)
end

-- ------------------------------------------------------------------------------
-- Mod Initialization
-- ------------------------------------------------------------------------------
print("[DialogSkipper] Initializing Tiny Tina's Wonderlands Dialogue Skipper Mod...")

SafeRegisterKeyBind(CONFIG.SkipKey, function()
    SkipActiveDialogue()
end)

if CONFIG.EnableFastForward and CONFIG.FastForwardKey then
    SafeRegisterKeyBind(CONFIG.FastForwardKey, function()
        ToggleFastForward()
    end)
end

print(string.format("[DialogSkipper] Ready! Press [F6] to skip dialogue | [F7] to toggle fast-forward (%0.1fx).", CONFIG.FastForwardSpeed))
