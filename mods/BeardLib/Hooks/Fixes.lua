local F = table.remove(RequiredScript:split("/"))
if F == "weaponfactorymanager" then
    --Custom weapons crash fix based of Rokk's mod.
    --I wish I could make a warning dialog for custom weapon crash fix but you'd need to pause the save manager or something..
    local orig_unpack = WeaponFactoryManager.unpack_blueprint_from_string
    function WeaponFactoryManager:unpack_blueprint_from_string(factory_id, ...)
        local factory = tweak_data.weapon.factory
        if not factory[factory_id] then
            BeardLib:log("[Fixes][Warning] Weapon with the factory ID %s does not exist, returning empty table.", tostring(factory_id))
            return {}
        end
        return orig_unpack(self, factory_id, ...)
    end
    local orig_has = WeaponFactoryManager.has_perk
    function WeaponFactoryManager:has_perk(perk_name, factory_id, blueprint, ...)
        for _, part_id in pairs(blueprint) do
            if not tweak_data.weapon.factory.parts[part_id] then
                BeardLib:log("[Fixes][Warning] Weapon mod with the ID '%s' was found in the save but was missing, the weapon mod will be deleted from the save", tostring(part_id))
                return false
            end
        end
        return orig_has(self, perk_name, factory_id, blueprint, ...)
    end
    --https://github.com/simon-wh/PAYDAY-2-BeardLib/issues/112
    Hooks:PreHook(WeaponFactoryManager, "_read_factory_data", "BeardLibFixMissingParts", function(self)
        local tweak = tweak_data.weapon.factory
        for factory_id, data in pairs(tweak) do
            if factory_id ~= "parts" and type(data.uses_parts) == "table" then
                for i, part_id in pairs(data.uses_parts) do
                    if not tweak.parts[part_id] then
                        BeardLib:log("[Fixes][Warning] Weapon with the factory ID %s has the part %s defined but the part does not exist", tostring(factory_id), tostring(part_id))                        
                        table.remove(data.uses_parts, i)
                    end
                end
            end
        end
    end)
elseif F == "blackmarketmanager" then
    local orig_get = BlackMarketManager.get_silencer_concealment_modifiers
    function BlackMarketManager:get_silencer_concealment_modifiers(weapon, ...)
        local weapon_id = weapon.weapon_id or managers.weapon_factory:get_weapon_id_by_factory_id(weapon.factory_id)
        if tweak_data.weapon[weapon_id] then
            return orig_get(self, weapon, ...)
        else
            BeardLib:log("[Fixes][Warning] Weapon with the ID '%s' was found in the save but was missing, the weapon will be deleted from the save", tostring(weapon_id))		
            return 0
        end
    end
elseif F == "crewmanagementgui" then
    local orig = CrewManagementGui.populate_primaries
    --Blocks out custom weapons that are don't have support for AI.
    function CrewManagementGui:populate_primaries(i, data, ...)
        local res = orig(self, i, data, ...)
        for k, v in ipairs(data) do
            local fac_id = managers.weapon_factory:get_factory_id_by_weapon_id(v.name)
            if fac_id then
                local factory = tweak_data.weapon.factory[fac_id.."_npc"]
                if factory and factory.custom and not DB:has(Idstring("unit"), factory.unit:id()) then
                    v.buttons = {} 
                    v.unlocked = false
                    v.lock_texture = "guis/textures/pd2/lock_incompatible"
                    v.lock_text = managers.localization:text("menu_data_crew_not_allowed")
                end
            end
        end
        return res
    end
elseif F == "connectionnetworkhandler" then
    --Fixes level id being set wrong with custom maps
    function ConnectionNetworkHandler:sync_stage_settings_ignore_once(...)
        self:sync_stage_settings(...)
        self._ignore_stage_settings_once = true
    end
    
    local orig_sync_stage_settings = ConnectionNetworkHandler.sync_stage_settings
    function ConnectionNetworkHandler:sync_stage_settings(level_id_index, ...)
        if self._ignore_stage_settings_once then
            self._ignore_stage_settings_once = nil
            return
        end
        return orig_sync_stage_settings(self, level_id_index, ...)
    end
    
    function ConnectionNetworkHandler:lobby_sync_update_level_id_ignore_once(...)
        self:lobby_sync_update_level_id(...)
        self._ignore_update_level_id_once = true
    end
    
    local orig_lobby_sync_update_level_id = ConnectionNetworkHandler.lobby_sync_update_level_id
    function ConnectionNetworkHandler:lobby_sync_update_level_id(level_id_index, ...)
        if self._ignore_update_level_id_once then
            self._ignore_update_level_id_once = nil
            return
        end
        return orig_lobby_sync_update_level_id(self, level_id_index, ...)
    end
elseif F == "elementinteraction" then
    --Checks if the interaction unit is loaded to avoid crashes
    core:import("CoreMissionScriptElement")
    ElementInteraction = ElementInteraction or class(CoreMissionScriptElement.MissionScriptElement)
    local orig_init = ElementInteraction.init
    local unit_ids = Idstring("unit")
    local norm_ids = Idstring("units/dev_tools/mission_elements/point_interaction/interaction_dummy")
    local nosync_ids = Idstring("units/dev_tools/mission_elements/point_interaction/interaction_dummy_nosync")
    function ElementInteraction:init(...)
        if not PackageManager:has(unit_ids, norm_ids) or not PackageManager:has(unit_ids, nosync_ids) then
            return ElementInteraction.super.init(self, ...)
        end
        return orig_init(self, ...)
    end
elseif F == "elementvehiclespawner" then
    --Same as interaction element but checks the selected vehicle
    core:import("CoreMissionScriptElement")
    ElementVehicleSpawner = ElementVehicleSpawner or class(CoreMissionScriptElement.MissionScriptElement)
    local orig_on_executed = ElementVehicleSpawner.on_executed
    local unit_ids = Idstring("unit")
    function ElementVehicleSpawner:on_executed(...)
        if not PackageManager:has(unit_ids, Idstring(self._vehicles[self._values.vehicle] or "")) then
            return
        end
        return orig_on_executed(self, ...)
    end
elseif F == "coresoundenvironmentmanager" then
    --From what I remember, this fixes a crash, these are useless in public.
    function CoreSoundEnvironmentManager:emitter_events(path)
        return {""}
    end
    function CoreSoundEnvironmentManager:ambience_events()
        return {""}
    end
end
