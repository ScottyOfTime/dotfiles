-- the same checks as yazi's escape, which doesn't say if it did anything
local busy = ya.sync(function()
	local tab = cx.active
	if tab.finder or tab.mode.is_visual or tab.current.files.filter or tab.current.cwd.is_search then
		return true
	end
	for _ in pairs(tab.selected) do
		return true
	end
	return false
end)

return {
	entry = function()
		ya.emit(busy() and "escape" or "quit", {})
	end,
}
