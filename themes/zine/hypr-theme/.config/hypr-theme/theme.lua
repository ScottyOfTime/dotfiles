---@module 'hl'

-- defaults fill any field colors.lua lacks: hyprland reloads on save, which
-- can be before darkman has rendered a newly added colour
local colors = { accent = "e08a43", ink = "0b0a09", cursor = "Bibata-Modern-Classic" }
local ok, rendered = pcall(dofile, os.getenv("HOME") .. "/.config/hypr-theme/colors.lua")
if ok then for k, v in pairs(rendered) do colors[k] = v end end

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
            color_inactive = "rgba(00000000)",
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
hl.animation({ leaf = "windowsMove",        enabled = true, speed = 4,   bezier = "pop" })
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

local mod = "SUPER"

hl.bind(mod .. " + Space",  hl.dsp.exec_cmd("qs ipc call launcher toggle"))
hl.bind(mod .. " + B",      hl.dsp.exec_cmd("qs ipc call bar toggle"))
hl.bind(mod .. " + Escape", hl.dsp.exec_cmd("qs ipc call power toggle"))
hl.bind(mod .. " + Tab",    hl.dsp.exec_cmd("qs ipc call overview toggle"))

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true, locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("qs ipc call osd brightness $(brightnessctl -m -e4 -n2 set 5%+ | cut -d, -f4 | tr -d %)"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("qs ipc call osd brightness $(brightnessctl -m -e4 -n2 set 5%- | cut -d, -f4 | tr -d %)"), { repeating = true, locked = true })

hl.layer_rule({
    name    = "quickshell-launcher",
    match   = { namespace = "^(launcher|powermenu|overview)$" },
    no_anim = true,
})

hl.layer_rule({
    name    = "static-wallpaper",
    match   = { namespace = "^wallpaper$" },
    no_anim = true,
})
