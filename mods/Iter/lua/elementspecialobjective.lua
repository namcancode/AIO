local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

if not Iter.settings.streamline_path then
	return
end

table.delete(ElementSpecialObjective._stealth_idles, 'e_so_ntl_idle_look3')
