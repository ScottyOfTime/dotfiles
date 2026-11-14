---@module 'hl'

-- defaults fill any field colors.lua lacks: hyprland reloads on save, which
-- can be before darkman has rendered a newly added colour
local colors = { accent = "ff3d8b", surface = "343437", cursor = "Bibata-Modern-Classic" }
local ok, rendered = pcall(dofile, os.getenv("HOME") .. "/.config/hypr-theme/colors.lua")
if ok then for k, v in pairs(rendered) do colors[k] = v end end

hl.env("XCURSOR_THEME", colors.cursor)
hl.env("XCURSOR_SIZE", 24)
hl.env("HYPRCURSOR_THEME", colors.cursor)
hl.env("HYPRCURSOR_SIZE", 24)

hl.config({
    general = {
        gaps_in     = 0,
        gaps_out    = 0,
        border_size = 2,
        col = {
            active_border   = "rgb(" .. colors.accent .. ")",
            inactive_border = "rgb(" .. colors.surface .. ")",
        },
    },
})

hl.config({
    decoration = {
        rounding     = 0,
        dim_inactive = false,
        shadow       = { enabled = false },
        blur         = { enabled = false },
    },
})

hl.config({ animations = { enabled = true } })

-- straight lines, short and with no overshoot: low tech, nothing springs
hl.curve("snap", { type = "bezier", points = { { 0.2, 0.9 }, { 0.3, 1 } } })
hl.curve("lin",  { type = "bezier", points = { { 0, 0 },     { 1, 1 } } })

hl.animation({ leaf = "global",              enabled = true, speed = 2,   bezier = "snap" })
hl.animation({ leaf = "windowsIn",           enabled = true, speed = 1.5, bezier = "snap", style = "popin 92%" })
hl.animation({ leaf = "windowsOut",          enabled = true, speed = 1,   bezier = "lin",  style = "popin 92%" })
hl.animation({ leaf = "windowsMove",         enabled = true, speed = 2,   bezier = "snap" })
hl.animation({ leaf = "fade",                enabled = true, speed = 1.5, bezier = "lin" })
hl.animation({ leaf = "border",              enabled = false })
hl.animation({ leaf = "layers",              enabled = true, speed = 1.5, bezier = "snap", style = "fade" })
hl.animation({ leaf = "workspaces",          enabled = true, speed = 2,   bezier = "snap", style = "slidefade 12%" })
hl.animation({ leaf = "specialWorkspace",    enabled = true, speed = 2,   bezier = "snap", style = "slidefadevert 12%" })
hl.animation({ leaf = "zoomFactor",          enabled = true, speed = 2,   bezier = "snap" })

local mod = "SUPER"

hl.bind(mod .. " + Space",  hl.dsp.exec_cmd("qs ipc call launcher toggle"))
hl.bind(mod .. " + B",      hl.dsp.exec_cmd("qs ipc call bar toggle"))
hl.bind(mod .. " + Escape", hl.dsp.exec_cmd("qs ipc call power toggle"))

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true, locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("qs ipc call osd brightness $(brightnessctl -m -e4 -n2 set 5%+ | cut -d, -f4 | tr -d %)"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("qs ipc call osd brightness $(brightnessctl -m -e4 -n2 set 5%- | cut -d, -f4 | tr -d %)"), { repeating = true, locked = true })

hl.layer_rule({
    name    = "quickshell-launcher",
    match   = { namespace = "^(launcher|powermenu)$" },
    no_anim = true,
})

hl.layer_rule({
    name    = "static-wallpaper",
    match   = { namespace = "^wallpaper$" },
    no_anim = true,
})
