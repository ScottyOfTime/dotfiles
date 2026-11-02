---@module 'hl'

-- scale from each screen's pixel density, so a new machine needs no setup:
-- a laptop panel sits nearer the eyes than a desk monitor, so it keeps more
-- density per logical pixel (the desktop's 108ppi monitors land on 1.33, a
-- 14" 1920x1200 laptop on 1.2; 1.25 and 1.5 there looked too big). Only
-- scales that divide the mode evenly, as others blur; screens that report
-- no size get Hyprland's own guess.
local SCALES = { 1, 1.2, 1.25, 4 / 3, 1.5, 5 / 3, 2, 2.5, 3 }
local function fitted_scale(m)
    if (m.physical_height or 0) <= 0 then return "auto" end
    local ppi = m.height / (m.physical_height / 25.4)
    local internal = m.name:match("^eDP") or m.name:match("^LVDS") or m.name:match("^DSI")
    local want = ppi / (internal and 140 or 81)
    local best = 1
    for _, s in ipairs(SCALES) do
        local w, h = m.width / s, m.height / s
        local even = math.abs(w - math.floor(w + 0.5)) < 0.01 and math.abs(h - math.floor(h + 0.5)) < 0.01
        if even and math.abs(s - want) < math.abs(best - want) then best = s end
    end
    return best
end
local function scale_monitors()
    for _, m in ipairs(hl.get_monitors()) do
        hl.monitor({ output = m.name, mode = "preferred", position = "auto", scale = fitted_scale(m) })
    end
end
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
scale_monitors()
hl.on("monitor.added", scale_monitors)

-- optional per-machine extras live in hosts/<hostname>.lua: workspace
-- pinning, rules, monitor overrides, and it may return
-- { autostart = { "app", ... } }
local hostname = io.open("/proc/sys/kernel/hostname")
local host = hostname and hostname:read("l") or ""
if hostname then hostname:close() end
local host_file = os.getenv("HOME") .. "/.config/hypr/hosts/" .. host .. ".lua"
local found = io.open(host_file)
local host_config = {}
if found then
    found:close()
    host_config = dofile(host_file) or {}
end

local terminal = "ghostty"

hl.on("hyprland.start", function()
    -- monitors may not exist yet when the config first loads
    scale_monitors()
    hl.exec_cmd("~/.config/hypr-theme/start")
    hl.exec_cmd("hypridle")
    hl.exec_cmd([[ghostty -e sh -c "fastfetch; exec $SHELL"]])
    for _, app in ipairs(host_config.autostart or {}) do
        hl.exec_cmd(app)
    end
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
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("~/.config/hypr/scripts/files.sh"))
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

hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("~/.config/hypr/scripts/special.sh magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mainMod .. " + grave", hl.dsp.exec_cmd("~/.config/hypr/scripts/dropdown.sh"))

hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("~/.config/hypr/scripts/special.sh music"))
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

hl.window_rule({
    name      = "dropdown-terminal",
    match     = { class = "^com\\.scotty\\.dropdown$" },
    workspace = "special:dropdown",
    float     = true,
    size      = "monitor_w*0.7 monitor_h*0.55",
    move      = "monitor_w*0.15 60",
})

hl.window_rule({
    name   = "files",
    match  = { class = "^com\\.scotty\\.files(pad)?$" },
    float  = true,
    size   = "monitor_w*0.6 monitor_h*0.6",
    center = true,
})

hl.window_rule({
    name      = "files-scratchpad",
    match     = { class = "^com\\.scotty\\.filespad$" },
    workspace = "special:files",
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
