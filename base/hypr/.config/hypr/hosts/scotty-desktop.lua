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

-- discord forks/re-execs itself, so an exec-time workspace loses track of
-- it; class-matched rules are reliable
hl.window_rule({
    name      = "discord-workspace",
    match     = { class = "^discord$" },
    workspace = "3 silent",
})

hl.window_rule({
    name      = "signal-workspace",
    match     = { class = "^signal$" },
    workspace = "3 silent",
})

return {
    autostart = { "discord", "signal-desktop", "steam", "spotify-launcher" },
}
