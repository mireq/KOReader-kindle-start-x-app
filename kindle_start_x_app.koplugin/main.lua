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
    local ffi = require("ffi")
    local C = ffi.C

    local ok, FBInkInput = pcall(ffi.loadlib, "fbink_input", 1)
    if not ok then
        print("fbink_input not loaded")
        return
    end

    Device.input.input:closeAll()
    if Device.touch_dev ~= nil then
        Device.input:close(Device.touch_dev)
    end

    os.execute("LD_LIBRARY_PATH= " .. args)

    local dev_count = ffi.new("size_t[1]")
    local match_mask = bit.bor(C.INPUT_TOUCHSCREEN, C.INPUT_SCALED_TABLET, C.INPUT_PAGINATION_BUTTONS, C.INPUT_HOME_BUTTON, C.INPUT_DPAD)
    local devices = FBInkInput.fbink_input_scan(match_mask, 0, 0, dev_count)
    if devices ~= nil then
        for i = 0, tonumber(dev_count[0]) - 1 do
            local dev = devices[i]
            if dev.matched then
                Device.input:fdopen(tonumber(dev.fd), ffi.string(dev.path), ffi.string(dev.name))
            end
        end
        C.free(devices)
    end

    Device.input:open("fake_events")

    UIManager:nextTick(function() UIManager:setDirty("all", "full") end)
end


return Xapp
