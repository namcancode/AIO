RenderSettings.currentSecond = tonumber(os.date("%S"))
if ( RenderSettings.currentSecond == RenderSettings.lastSecond ) then
	RenderSettings.frameCount = RenderSettings.frameCount + 1
else
	if ( RenderSettings.frameCount ) then
		RenderSettings.needsFix = ( RenderSettings.frameCount < 29 )
	end
	RenderSettings.frameCount = 0
	RenderSettings.lastSecond = RenderSettings.currentSecond
end

if ( RenderSettings.needsFix ) then
	managers.user:set_setting("flush_gpu_command_queue", not managers.user:get_setting("flush_gpu_command_queue"))
	RenderSettings.needsFix = false
end