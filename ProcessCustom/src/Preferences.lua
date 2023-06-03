
local rd = renoise.Document
local vb = renoise.ViewBuilder()

local settings = renoise.Document.create("ScriptingToolPreferences") {
    process_window_size         = 4410,
    process_menu_entry_crumb    = 'Mogue Process'
}

renoise.tool().preferences = settings

-- renoise.app():show_message( "" .. settings.process_frame_size.value )

local  guiSettings = function ()
    local g_window_size  = vb:valuebox  { min= 1, max= 192000,  value=settings.process_window_size.value  }
    local g_menu_entry   = vb:textfield { width= 160, text=settings.process_menu_entry_crumb.value }

    local view = vb:column {
        margin= 8, spacing= 4,
        vb:row { vb:text { width = 160, text="Process window size: (samples)" }, g_window_size },
        vb:text { width = 160, text="Menu entry path:" },
        g_menu_entry
    }

    renoise.app():show_custom_dialog("Custom Process Settings", view )
end

return {
    settings = settings,
    guiSettings = guiSettings,
}