Hooks:PostHook(MenuInput, "init", "BeardLibMenuInputInit", function(self)
	self._item_input_action_map[MenuItemColorButton.TYPE] = callback(self, self, "input_color_item")
end)

local back = MenuInput.back
function MenuInput:back(...)
    if BeardLib.IgnoreBackOnce then
        BeardLib.IgnoreBackOnce = nil
        return false
    end
    return back(self, ...)
end

local mm = MenuInput.mouse_moved
function MenuInput:MenuUINotActive(...)
    local mc = managers.mouse_pointer._mouse_callbacks
    local last = mc[#mc]
    return not last or type_name(last.parent) ~= "MenuUI" or last.parent.allow_full_input
end

function MenuInput:mouse_moved(...)
    if self:MenuUINotActive() and not self:BeardLibMouseMoved(...) then
        return mm(self, ...)
    end
end

local mp = MenuInput.mouse_pressed
function MenuInput:mouse_pressed(...)
    if self:MenuUINotActive() and not self:BeardLibMousePressed(...) then
        return mp(self, ...)
    end
end

Hooks:PostHook(MenuInput, "mouse_released", "BeardLibMenuInputMouseReleased", function(self, ...)
    self:BeardLibMouseReleased(...)
end)

function MenuInput:BeardLibMouseMoved(o, x, y)
    if self._current_input_item and self._current_input_item.mouse_moved then
        return self._current_input_item:mouse_moved(self:_modified_mouse_pos(x, y))
    end
    return false
end

local color_button = "color_button"
local slider = "slider"

function MenuInput:BeardLibMousePressed(o, button, x, y)
    local item = self._logic:selected_item()

    if self._current_input_item then 
        return self._current_input_item:mouse_pressed(button, self:_modified_mouse_pos(x, y)) 
    end

    if item then
        if button == Idstring("1") then
            if (item.TYPE == slider or item._parameters.input) then
                self._current_item = item
                local title = item._parameters.text_id
                BeardLib.managers.dialog:Input():Show({
                    title = item._parameters.override_title or item._parameters.localize ~= false and managers.localization:text(title) or title, 
                    text = tostring(item._value) or item._parameters.string_value or "",
                    filter = item._value and "number",
                    floats = item._decimal_count ~= 2 and item._decimal_count or nil,
                    force = true,
                    no_blur = true,
                    callback = callback(self, self, "ValueEnteredCallback")
                })
                return true
            elseif item.TYPE == color_button then
                item:set_editing(true)
                self._current_input_item = item
                item:mouse_pressed(button, self:_modified_mouse_pos(x, y)) 
                return true
            end
        elseif button == Idstring("0") and item.TYPE == color_button then
            self._current_item = item
            local title = item._parameters.text_id
            BeardLib.managers.dialog:Color():Show({
                title = item._parameters.override_title or item._parameters.localize ~= false and managers.localization:text(title) or title, 
                color = item:value(),
                force = true,
                no_blur = true,
                callback = callback(self, self, "ValueEnteredCallback")
            })
            return true
        end
    end
    return false
end

function MenuInput:BeardLibMouseReleased(o, button, x, y)
    if self._current_input_item and self._current_input_item.mouse_released then
        return self._current_input_item:mouse_released(button, self:_modified_mouse_pos(x, y))
    end
end

function MenuInput:ValueEnteredCallback(value)
    if self._current_item then
        if self._current_item.set_value then
            self._current_item:set_value(value)
        end
        self._current_item:trigger()
        self._current_item = nil
    end
end

function MenuInput:input_color_item(item, controller, mouse_click)
	if controller:get_input_pressed("confirm") then
        local node_gui = managers.menu:active_menu().renderer:active_node_gui()
        if node_gui and node_gui._listening_to_input then
            return
        end

        self._logic:trigger_item(true, item)
        self:select_node()
	end
end

local up = MenuInput.update
function MenuInput:update(...)
    self:any_keyboard_used()
    if self._accept_input then
        if self._controller then
            if self:MenuUINotActive() then
                up(self, ...)
            end
        end
    else
        up(self, ...)
    end
end