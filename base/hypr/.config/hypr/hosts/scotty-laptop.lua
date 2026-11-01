---@module 'hl'

-- 1920x1200: auto picked 1.5 (1280x800 of space, everything huge); 1.25
-- divides it evenly into 1536x960
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1.25,
})
