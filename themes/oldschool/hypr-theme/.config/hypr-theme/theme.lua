---@module 'hl'

-- defaults fill any field colors.lua lacks: hyprland reloads on save, which
-- can be before darkman has rendered a newly added colour
local colors = { cursor = "whiteglass" }
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
        border_size = 0,
    },
})

hl.config({
    decoration = {
        rounding     = 0,
        dim_inactive = false,
        shadow       = { enabled = false },
        glow         = { enabled = false },
        blur         = { enabled = false },
    },
})

hl.config({ animations = { enabled = false } })

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
