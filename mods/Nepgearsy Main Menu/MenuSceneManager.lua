Hooks:PostHook( MenuSceneManager, "_set_up_templates", "nepmenu_setup_templates", function(self)
	self._scene_templates.standard.character_pos = Vector3(-12, -45, -140)
	self._scene_templates.standard.character_rot = -170
	self._scene_templates.standard.hide_menu_logo = true

	self._scene_templates.standard.use_character_grab = false
	self._scene_templates.options.use_character_grab = false
	self._scene_templates.character_customization.use_character_grab = false

	self._scene_templates.standard.lights = {
		self:_create_light({
			far_range = 400,
			color = Vector3(0.86, 0.37, 0.21) * 4,
			position = Vector3(180, -100, 0)
		}),
		self:_create_light({
			far_range = 650,
			specular_multiplier = 8,
			color = Vector3(0.3, 0.5, 0.8) * 6,
			position = Vector3(-180, -100, 32)
		}),
		self:_create_light({
			far_range = 600,
			specular_multiplier = 0,
			color = Vector3(1, 1, 1) * 0.35,
			position = Vector3(-180, -250, -40)
		})
	}
end)

Hooks:PostHook( MenuSceneManager, "set_scene_template", "nepmenu_set_scene_template", function(self, template, data, custom_name, skip_transition)
	local template_data = nil

	if not skip_transition then
		template_data = data or self._scene_templates[template]

		if template_data.character_rot then
			self._character_unit:set_rotation(Rotation(template_data.character_rot, self._character_pitch))
            self._character_yaw = template_data.character_rot
		end
	end
end)

Hooks:PostHook( MenuSceneManager, "_select_character_pose", "nepmenu_select_pose", function(self, unit)
	unit = unit or self._character_unit
	local pose = "husk_m95"
	self:_set_character_unit_pose(pose, unit)
end)