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
		if busy() then
			ya.emit("escape", {})
		elseif os.getenv("DOTFILES_FILES_PAD") then
			-- mod+E's scratchpad yazi (hypr/scripts/files.sh): hide, stay running
			Command("hyprctl"):arg({ "dispatch", 'hl.dsp.workspace.toggle_special("files")' }):stdout(Command.NULL):status()
		else
			ya.emit("quit", {})
		end
	end,
}
