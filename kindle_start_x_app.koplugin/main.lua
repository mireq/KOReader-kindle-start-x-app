local Dispatcher = require("dispatcher")  -- luacheck:ignore
local InfoMessage = require("ui/widget/infomessage")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local Device = require("device")
local logger = require("logger")
local commands = require("commands")
local _ = require("gettext")


local Xapp = WidgetContainer:new{
    name = "kindle_start_x_app",
    is_doc_only = false,
}

function Xapp:onDispatcherRegisterActions()
    --Dispatcher:registerAction("startxapp_action", {category="none", event="StartXapp", title=_("Start Xapp"), general=true,})
end

function Xapp:init()
    self:onDispatcherRegisterActions()
    self.ui.menu:registerToMainMenu(self)
end

function Xapp:addToMainMenu(menu_items)
    for key, command in pairs(commands) do
        local sorting_hint = "more_tools"
        if command.sorting_hint ~= nil then
            sorting_hint = command.sorting_hint
        end
        menu_items['start_xapp_' .. key] = {
            text = command.text,
            sorting_hint = sorting_hint,
            callback = function()
                self:startXapp(command.command)
            end,
        }
    end
end

function Xapp:startXapp(args)
    if Device.touch_dev ~= nil then
        Device.input:close(Device.touch_dev)
    end
    os.execute("LD_LIBRARY_PATH= " .. args)
    if Device.touch_dev ~= nil then
        Device.input:open(Device.touch_dev)
    end
    UIManager:nextTick(function() UIManager:setDirty("all", "full") end)
end


return Xapp
