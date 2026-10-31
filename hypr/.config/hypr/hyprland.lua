---@module 'hl'

local WOBSOCK = os.getenv("XDG_RUNTIME_DIR") .. "/wob.sock"

local ok, colors = pcall(dofile, os.getenv("HOME") .. "/.config/hypr/colors.lua")
if not ok then colors = { accent = "e3863a", ink = "0b0a09", shade = "141210", cursor = "Bibata-Modern-Classic" } end

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
local menu        = "fuzzel"

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("~/.config/hypr/scripts/wallpaper.sh")
    hl.exec_cmd("~/.config/hypr/scripts/wob.sh")
    hl.exec_cmd("hypridle")
    hl.exec_cmd([[ghostty -e sh -c "fastfetch; exec $SHELL"]])
    hl.exec_cmd("discord")
    hl.exec_cmd("signal-desktop", { workspace = "3 silent" })
    hl.exec_cmd("steam")
    hl.exec_cmd("spotify-launcher")
end)

hl.env("XCURSOR_THEME", colors.cursor)
hl.env("XCURSOR_SIZE", 24)
hl.env("HYPRCURSOR_THEME", colors.cursor)
hl.env("HYPRCURSOR_SIZE", 24)

hl.config({
    general = {
        gaps_in     = 8,
        gaps_out    = 16,
        border_size = 2,
        col = {
            active_border   = "rgb(" .. colors.ink .. ")",
            inactive_border = "rgb(" .. colors.ink .. ")",
        },
    },
})

hl.config({
    decoration = {
        rounding     = 10,
        dim_inactive = true,
        dim_strength = 0.08,
        shadow = {
            enabled        = true,
            sharp          = true,
            range          = 1,
            offset         = { 6, 6 },
            color          = "rgb(" .. colors.accent .. ")",
            color_inactive = "rgb(" .. colors.shade .. ")",
        },
    },
})

hl.config({ animations = { enabled = true } })

-- overshoot past 1 is what gives the pop
hl.curve("pop",   { type = "bezier", points = { { 0.18, 1.35 }, { 0.4, 1 } } })
hl.curve("out",   { type = "bezier", points = { { 0.23, 1 },    { 0.32, 1 } } })
hl.curve("in",    { type = "bezier", points = { { 0.55, 0 },    { 1, 0.45 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 },    { 0.1, 1 } } })

hl.animation({ leaf = "global",             enabled = true, speed = 3,   bezier = "out" })
hl.animation({ leaf = "windowsIn",          enabled = true, speed = 2.5, bezier = "pop", style = "popin 80%" })
hl.animation({ leaf = "windowsOut",         enabled = true, speed = 1.5, bezier = "in",  style = "popin 85%" })
hl.animation({ leaf = "windowsMove",        enabled = true, speed = 2.5, bezier = "pop" })
hl.animation({ leaf = "fadeIn",             enabled = true, speed = 1.5, bezier = "out" })
hl.animation({ leaf = "fadeOut",            enabled = true, speed = 1.5, bezier = "in" })
hl.animation({ leaf = "fadeDim",            enabled = true, speed = 2,   bezier = "out" })
hl.animation({ leaf = "border",             enabled = true, speed = 2,   bezier = "out" })
hl.animation({ leaf = "layersIn",           enabled = true, speed = 2.5, bezier = "pop", style = "slide" })
hl.animation({ leaf = "layersOut",          enabled = true, speed = 1.5, bezier = "in",  style = "slide" })
hl.animation({ leaf = "fadeLayersIn",       enabled = true, speed = 1.5, bezier = "out" })
hl.animation({ leaf = "fadeLayersOut",      enabled = true, speed = 1.2, bezier = "in" })
hl.animation({ leaf = "workspaces",         enabled = true, speed = 2.5, bezier = "out", style = "slide" })
hl.animation({ leaf = "specialWorkspaceIn", enabled = true, speed = 2.5, bezier = "pop", style = "slidevert" })
hl.animation({ leaf = "specialWorkspaceOut",enabled = true, speed = 1.8, bezier = "in",  style = "slidevert" })
hl.animation({ leaf = "zoomFactor",         enabled = true, speed = 3,   bezier = "quick" })

hl.config({
    input = { touchpad = { natural_scroll = true } },
})

hl.gesture({
    ["fingers"]   = 3,
    ["direction"] = "horizontal",
    ["action"]    = "workspace",
})

local mainMod = "SUPER"

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + W", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float())
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

for i = 1, 10 do
    local key = tostring(i % 10)
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mainMod .. " + M", hl.dsp.workspace.toggle_special("music"))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.window.move({ workspace = "special:music" }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+ && wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}' > " .. WOBSOCK), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}' > " .. WOBSOCK), { repeating = true, locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { repeating = true, locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+ && brightnessctl get | awk -v max=$(brightnessctl max) '{print int($1/max*100)}' > " .. WOBSOCK), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%- && brightnessctl get | awk -v max=$(brightnessctl max) '{print int($1/max*100)}' > " .. WOBSOCK), { repeating = true, locked = true })

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl -p spotify,%any next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl -p spotify,%any play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl -p spotify,%any play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl -p spotify,%any previous"), { locked = true })

hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("pkill -SIGUSR1 waybar"))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("darkman toggle"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("pidof hyprlock || hyprlock"))
hl.bind(mainMod .. " + minus", hl.dsp.exec_cmd("wtype –"), { release = true })
hl.bind("Print", hl.dsp.exec_cmd("mkdir -p ~/screenshots && flameshot gui --path ~/screenshots --clipboard"))

hl.config({
    xwayland = { force_zero_scaling = true },
})

hl.layer_rule({
    name    = "static-wallpaper",
    match   = { namespace = "^wallpaper$" },
    no_anim = true,
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
