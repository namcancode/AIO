local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

if not FullSpeedSwarm then
	Hooks:PostHook(EnemyManager, "_update_queued_tasks" , "KPR_EnemyManagerPostUpdateQueuedTasks" , function(self, t)
		local converted = managers.groupai:state()._converted_police
		if next(converted) then
			local n = 4
			local i_task = 1
			local task_data = self._queued_tasks[1]
			while task_data do
				local u = task_data.data.unit
				if u and (not task_data.t or t > task_data.t) and converted[u:key()] then
					self:_execute_queued_task(i_task)
					n = n - 1
					if n <= 0 then
						break
					end
				else
					i_task = i_task + 1
				end
				task_data = self._queued_tasks[i_task]
			end
		end
	end)
end
