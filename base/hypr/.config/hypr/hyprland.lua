---@module 'hl'

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1.33,
})

hl.workspace_rule({ workspace = "1", monitor = "DP-2" })
hl.workspace_rule({ workspace = "2", monitor = "DP-2" })
hl.workspace_rule({ workspace = "3", monitor = "DP-3" })
hl.workspace_rule({ workspace = "4", monitor = "DP-3" })

local terminal    = "ghostty"
local fileManager = "dolphin"

hl.on("hyprland.start", function()
    hl.exec_cmd("~/.config/hypr-theme/start")
    hl.exec_cmd("hypridle")
    hl.exec_cmd([[ghostty -e sh -c "fastfetch; exec $SHELL"]])
    hl.exec_cmd("discord")
    hl.exec_cmd("signal-desktop", { workspace = "3 silent" })
    hl.exec_cmd("steam")
    hl.exec_cmd("spotify-launcher")
end)

hl.config({
    input  = { repeat_delay = 250, repeat_rate = 40, touchpad = { natural_scroll = true } },
    binds  = { workspace_back_and_forth = true },
    cursor = { hide_on_key_press = true, no_warps = true },
    -- lets a new locker take over if the theme's locker dies while locked
    misc   = { allow_session_lock_restore = true, enable_swallow = true, swallow_regex = "^com\\.mitchellh\\.ghostty$" },
})

hl.gesture({
    ["fingers"]   = 3,
    ["direction"] = "horizontal",
    ["action"]    = "workspace",
})

local mainMod = "SUPER"

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + W", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float())
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

for _, dir in ipairs({ "left", "right", "up", "down" }) do
    hl.bind(mainMod .. " + SHIFT + " .. dir, hl.dsp.window.move({ direction = dir }))
end
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.window.resize({ x = -60, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x = 60, y = 0, relative = true }),  { repeating = true })
hl.bind(mainMod .. " + CTRL + up",    hl.dsp.window.resize({ x = 0, y = -60, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.window.resize({ x = 0, y = 60, relative = true }),  { repeating = true })

for i = 1, 10 do
    local key = tostring(i % 10)
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mainMod .. " + grave", hl.dsp.exec_cmd("~/.config/hypr/scripts/dropdown.sh"))

hl.bind(mainMod .. " + M", hl.dsp.workspace.toggle_special("music"))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.window.move({ workspace = "special:music" }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl -p spotify,%any next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl -p spotify,%any play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl -p spotify,%any play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl -p spotify,%any previous"), { locked = true })

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("darkman toggle"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("~/.config/hypr-theme/lock"))
hl.bind(mainMod .. " + minus", hl.dsp.exec_cmd("wtype –"), { release = true })
hl.bind("Print", hl.dsp.exec_cmd("mkdir -p ~/screenshots && flameshot gui --path ~/screenshots --clipboard"))

hl.config({
    xwayland = { force_zero_scaling = true },
})

hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move  = { 20, "monitor_h-120" },
    float = true,
})

-- flameshot's capture overlay must float at the origin to cover the screen
hl.window_rule({
    name  = "flameshot-overlay",
    match = { class = "^flameshot$" },
    float = true,
    pin   = true,
    move  = { 0, 0 },
})

-- Discord forks/re-execs itself, so the exec-time workspace rule loses track
-- of it and it opens wherever focus is. A class-matched rule is reliable.
hl.window_rule({
    name      = "discord-workspace",
    match     = { class = "^discord$" },
    workspace = "3 silent",
})

hl.window_rule({
    name      = "dropdown-terminal",
    match     = { class = "^com\\.scotty\\.dropdown$" },
    workspace = "special:dropdown",
    float     = true,
    size      = "monitor_w*0.7 monitor_h*0.55",
    move      = "monitor_w*0.15 60",
})

hl.window_rule({
    name      = "steam-workspace",
    match     = { class = "^steam$" },
    workspace = "special:magic silent",
})

-- spotify-launcher runs the real client, whose class is "Spotify" (X11) or "spotify" (Wayland)
hl.window_rule({
    name      = "spotify-workspace",
    match     = { class = "^(?i)spotify$" },
    workspace = "special:music silent",
})

-- the active theme (./theme <name>) adds its look, animations and binds for
-- its own bar, launcher and popups; a broken theme must not take base down
pcall(dofile, os.getenv("HOME") .. "/.config/hypr-theme/theme.lua")
