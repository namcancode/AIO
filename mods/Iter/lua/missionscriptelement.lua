local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local level_id = Global.game_settings and Global.game_settings.level_id or ''
level_id = level_id:gsub('_night$', ''):gsub('_day$', '')
local itr_original_missionscriptelement_onexecuted = MissionScriptElement.on_executed

if not Iter.settings["map_change_" .. level_id] then

elseif level_id == "mad" then

	function MissionScriptElement:on_executed(...)
		itr_original_missionscriptelement_onexecuted(self, ...)
		if self._id == 137499 then
			managers.navigation:clbk_navfield("remove_nav_seg_neighbours", { [13] = {9} })
			managers.navigation:clbk_navfield("remove_nav_seg_neighbours", { [9] = {13} })
		end
	end

elseif level_id == "mia_1" then

	local entrance_id
	local trap_links = {
		{ 20, 113 },
		{ 22, 119 },
		{  9, 100 },
		{ 26,  11 },
		{ 12, 117 }
	}
	function MissionScriptElement:on_executed(...)
		itr_original_missionscriptelement_onexecuted(self, ...)
		if self._id == 101242 then
			entrance_id = self._values.on_executed[1].id - 101242
			for k, v in pairs(trap_links) do
				managers.navigation:clbk_navfield("remove_nav_seg_neighbours", { [v[1]] = {v[2]} })
				managers.navigation:clbk_navfield("remove_nav_seg_neighbours", { [v[2]] = {v[1]} })
			end
		elseif self._id == 104635 then
			local v = trap_links[entrance_id]
			managers.navigation:clbk_navfield("add_nav_seg_neighbours", { [v[1]] = {v[2]} })
			managers.navigation:clbk_navfield("add_nav_seg_neighbours", { [v[2]] = {v[1]} })
		end
	end

end

ElementAINavSeg = ElementAINavSeg or class(CoreMissionScriptElement.MissionScriptElement)
function ElementAINavSeg:init(...)
	ElementAINavSeg.super.init(self, ...)
end

function ElementAINavSeg:on_script_activated()
end

function ElementAINavSeg:client_on_executed(...)
	self:on_executed(...)
end

function ElementAINavSeg:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local segs = self._values.segment_ids
	for i = 1, #segs, 2 do
		managers.navigation:clbk_navfield(self._values.operation, { [segs[i]] = {segs[i + 1]} })
	end

	ElementAINavSeg.super.on_executed(self, instigator)
end
