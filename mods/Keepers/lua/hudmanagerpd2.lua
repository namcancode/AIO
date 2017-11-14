local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local kpr_original_hudmanager_addnamelabel = HUDManager._add_name_label
function HUDManager:_add_name_label(data)
	local u_mov = data.unit:movement()
	for _, label in ipairs(self._hud.name_labels) do
		if label.movement == u_mov then
			self:_remove_name_label(label.id)
			break
		end
	end

	return kpr_original_hudmanager_addnamelabel(self, data)
end
