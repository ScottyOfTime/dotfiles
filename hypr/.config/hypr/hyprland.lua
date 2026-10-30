---@module 'hl'

-- See https://wiki.hypr.land/Configuring/ for the full reference

local WOBSOCK = os.getenv("XDG_RUNTIME_DIR") .. "/wob.sock"

-- colours rendered by darkman from ~/.config/palette, ayu dark until it has run
local ok, colors = pcall(dofile, os.getenv("HOME") .. "/.config/hypr/colors.lua")
if not ok then colors = { accent = "e6b450", shadow = "06070a", cursor = "Bibata-Modern-Amber" } end

--###############
--## MONITORS ###
--###############

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1.33,
})

--#################
--## WORKSPACES ###
--#################

-- Display 1 (DP-2, left) gets workspaces 1-2, display 2 (DP-3, right) gets 3-4
hl.workspace_rule({ workspace = "1", monitor = "DP-2" })
hl.workspace_rule({ workspace = "2", monitor = "DP-2" })
hl.workspace_rule({ workspace = "3", monitor = "DP-3" })
hl.workspace_rule({ workspace = "4", monitor = "DP-3" })

--##################
--## MY PROGRAMS ###
--##################

local terminal    = "ghostty"
local fileManager = "dolphin"
local menu        = "fuzzel"

--################
--## AUTOSTART ###
--################

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

--############################
--## ENVIRONMENT VARIABLES ###
--############################

hl.env("XCURSOR_THEME", colors.cursor)
hl.env("XCURSOR_SIZE", 24)
hl.env("HYPRCURSOR_THEME", colors.cursor)
hl.env("HYPRCURSOR_SIZE", 24)

--####################
--## LOOK AND FEEL ###
--####################

hl.config({
    general = {
        gaps_in     = 0,
        gaps_out    = 0,
        border_size = 0,
        resize_on_border = false,
        allow_tearing    = false,
        layout = "dwindle",
        col = {
            active_border   = "rgb(" .. colors.accent .. ")",
            inactive_border = "rgb(" .. colors.shadow .. ")",
        },
    },
})

hl.config({
    decoration = {
        rounding       = 0,
        rounding_power = 2,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = "rgba(1a1a1aee)",
        },
        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },
})

hl.config({ animations = { enabled = true } })

hl.curve("easeOutQuint",   { type = "bezier", points = { { 0.23, 1 },    { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear",         { type = "bezier", points = { { 0, 0 },       { 1, 1 } } })
hl.curve("almostLinear",   { type = "bezier", points = { { 0.5, 0.5 },   { 0.75, 1 } } })
hl.curve("quick",          { type = "bezier", points = { { 0.15, 0 },    { 0.1, 1 } } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick" })

hl.config({
    master = { new_status = "master" },
    misc = {
        force_default_wallpaper  = -1,
        disable_hyprland_logo    = false,
    },
})

--############
--## INPUT ###
--############

hl.config({
    input = {
        kb_layout   = "us",
        follow_mouse = 1,
        sensitivity  = 0,
        touchpad = {
            natural_scroll = true,
        },
    },
})

hl.gesture({
    ["fingers"]   = 3,
    ["direction"] = "horizontal",
    ["action"]    = "workspace",
})

--##################
--## KEYBINDINGS ###
--##################

local mainMod = "SUPER"

hl.bind(mainMod .. " + " .. "Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + " .. "W", hl.dsp.window.close())
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "Q", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit"))
hl.bind(mainMod .. " + " .. "E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + " .. "V", hl.dsp.window.float())
hl.bind(mainMod .. " + " .. "Space", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + " .. "P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + " .. "J", hl.dsp.layout("togglesplit")) -- dwindle

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + " .. "left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + " .. "right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + " .. "up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + " .. "down",  hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
hl.bind(mainMod .. " + " .. 1, hl.dsp.focus({ workspace = 1 }))
hl.bind(mainMod .. " + " .. 2, hl.dsp.focus({ workspace = 2 }))
hl.bind(mainMod .. " + " .. 3, hl.dsp.focus({ workspace = 3 }))
hl.bind(mainMod .. " + " .. 4, hl.dsp.focus({ workspace = 4 }))
hl.bind(mainMod .. " + " .. 5, hl.dsp.focus({ workspace = 5 }))
hl.bind(mainMod .. " + " .. 6, hl.dsp.focus({ workspace = 6 }))
hl.bind(mainMod .. " + " .. 7, hl.dsp.focus({ workspace = 7 }))
hl.bind(mainMod .. " + " .. 8, hl.dsp.focus({ workspace = 8 }))
hl.bind(mainMod .. " + " .. 9, hl.dsp.focus({ workspace = 9 }))
hl.bind(mainMod .. " + " .. 0, hl.dsp.focus({ workspace = 10 }))

-- Move active window to a workspace with mainMod + SHIFT + [0-9]
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 1, hl.dsp.window.move({ workspace = 1 }))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 2, hl.dsp.window.move({ workspace = 2 }))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 3, hl.dsp.window.move({ workspace = 3 }))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 4, hl.dsp.window.move({ workspace = 4 }))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 5, hl.dsp.window.move({ workspace = 5 }))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 6, hl.dsp.window.move({ workspace = 6 }))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 7, hl.dsp.window.move({ workspace = 7 }))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 8, hl.dsp.window.move({ workspace = 8 }))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 9, hl.dsp.window.move({ workspace = 9 }))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. 0, hl.dsp.window.move({ workspace = 10 }))

-- Scratchpad
hl.bind(mainMod .. " + " .. "S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Music scratchpad
hl.bind(mainMod .. " + " .. "M", hl.dsp.workspace.toggle_special("music"))
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "M", hl.dsp.window.move({ workspace = "special:music" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + " .. "mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + " .. "mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + " .. "F", hl.dsp.window.fullscreen())

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + " .. "mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + " .. "mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+ && wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}' > " .. WOBSOCK), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}' > " .. WOBSOCK), { repeating = true, locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { repeating = true, locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+ && brightnessctl get | awk -v max=$(brightnessctl max) '{print int($1/max*100)}' > " .. WOBSOCK), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%- && brightnessctl get | awk -v max=$(brightnessctl max) '{print int($1/max*100)}' > " .. WOBSOCK), { repeating = true, locked = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl -p spotify,%any next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl -p spotify,%any play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl -p spotify,%any play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl -p spotify,%any previous"), { locked = true })

-- Waybar
hl.bind(mainMod .. " + " .. "B", hl.dsp.exec_cmd("pkill -SIGUSR1 waybar"))

-- Toggle light/dark mode
hl.bind(mainMod .. " + " .. "T", hl.dsp.exec_cmd("darkman toggle"))

-- Lock screen
hl.bind(mainMod .. " + " .. "L", hl.dsp.exec_cmd("pidof hyprlock || hyprlock"))

-- Type an en dash (requires wtype)
hl.bind(mainMod .. " + " .. "minus", hl.dsp.exec_cmd("wtype –"), { release = true })

-- Screenshot: select region, save to ~/screenshots and copy to clipboard
hl.bind("Print", hl.dsp.exec_cmd("mkdir -p ~/screenshots && flameshot gui --path ~/screenshots --clipboard"))

--#############################
--## WINDOWS AND WORKSPACES ###
--#############################

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
