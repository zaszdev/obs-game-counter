obs = obslua

PLAYER_COUNT = 4

players = {}

function script_description()
    return [[<center><h2>Game Changer Counter :3</h2></center>
            <p>Supports score up/down hotkeys for up to four players.</p>]]
end

-- Shamelessly yoinked from https://github.com/obsproject/obs-studio/wiki/scripting-tutorial-source-shake
function populate_list_property_with_source_names(list_property)
    local sources = obs.obs_enum_sources()
    obs.obs_property_list_clear(list_property)
    obs.obs_property_list_add_string(list_property, "", "")
    for _, source in pairs(sources) do
        local name = obs.obs_source_get_name(source)
        obs.obs_property_list_add_string(list_property, name, name)
    end
    obs.source_list_release(sources)
end

-- Called to define user properties of the script (under Tools -> Scripts)
function script_properties()
    local props = obs.obs_properties_create()
    for i, _ in ipairs(players) do
        local list_property = obs.obs_properties_add_list(props, "source" .. i .. "_name", "Player " .. i .. " Source",
            obs.OBS_COMBO_TYPE_LIST, obs.OBS_COMBO_FORMAT_STRING)
        populate_list_property_with_source_names(list_property)
    end
    return props
end

-- Update a text source with a given value
function update_source_with_value(source_name, value)
    local source = obs.obs_get_source_by_name(source_name)
    if not source then
        print("Text source '" .. source_name .. "' not found.")
        return
    end

    local settings = obs.obs_source_get_settings(source)
    obs.obs_data_set_string(settings, "text", tostring(value))
    obs.obs_source_update(source, settings)

    obs.obs_data_release(settings)
    obs.obs_source_release(source)
end

-- Generic hotkey handler
function make_hotkey_callback(index, value)
    return function(pressed)
        if pressed then
            local player = players[index]
            player.score = player.score + (value)
            update_source_with_value(player.source_name, player.score)
        end
    end
end

-- Called at script load
function script_load(settings)
    for i = 1, PLAYER_COUNT do
        local player = {}
        player.score = 0
        player.source_name = obs.obs_data_get_string(settings, "source" .. i .. "_name")

        -- Register UP hotkey
        player.up_hotkey_id = obs.obs_hotkey_register_frontend(
            script_path(),
            player.source_name .. " Score Up",
            make_hotkey_callback(i, 1)
        )
        local up = obs.obs_data_get_array(settings, "hotkey_player_up_" .. i)
        obs.obs_hotkey_load(player.up_hotkey_id, up)
        obs.obs_data_array_release(up)

        -- Register DOWN hotkey
        player.down_hotkey_id = obs.obs_hotkey_register_frontend(
            script_path(),
            player.source_name .. " Score Down",
            make_hotkey_callback(i, -1)
        )
        local down = obs.obs_data_get_array(settings, "hotkey_player_down_" .. i)
        obs.obs_hotkey_load(player.down_hotkey_id, down)
        obs.obs_data_array_release(down)

        table.insert(players, player)
    end
end

-- Called after script load and settings change
function script_update(settings)
    for i, player in ipairs(players) do
        player.source_name = obs.obs_data_get_string(settings, "source" .. i .. "_name")
    end
end

-- Called before settings are saved
function script_save(settings)
    for i, player in ipairs(players) do
        local up = obs.obs_hotkey_save(player.up_hotkey_id)
        obs.obs_data_set_array(settings, "hotkey_player_up_" .. i, up)
        obs.obs_data_array_release(up)

        local down = obs.obs_hotkey_save(player.down_hotkey_id)
        obs.obs_data_set_array(settings, "hotkey_player_down_" .. i, down)
        obs.obs_data_array_release(down)
    end
end
