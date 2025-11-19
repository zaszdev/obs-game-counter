obs = obslua

players = {
    {
        name = "Player 1",
        score = 0,
        up_hotkey_id = nil,
        down_hotkey_id = nil,
    },
    {
        name = "Player 2",
        score = 0,
        up_hotkey_id = nil,
        down_hotkey_id = nil,
    },
    {
        name = "Player 3",
        score = 0,
        up_hotkey_id = nil,
        down_hotkey_id = nil,
    },
    {
        name = "Player 4",
        score = 0,
        up_hotkey_id = nil,
        down_hotkey_id = nil,
    },
}

function script_description()
    return [[<center><h2>Game Changer Counter :3</h2></center>
            <p>Supports score up/down hotkeys for up to four players.</p>]]
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
function make_hotkey_callback(player_index, value)
    return function(pressed)
        if pressed then
            local p = players[player_index]

            p.score = p.score + (value)

            update_source_with_value(p.name, p.score)
        end
    end
end

-- Script load: register hotkeys
function script_load(settings)
    for idx, player in ipairs(players) do
        -- Register UP hotkey
        player.up_hotkey_id = obs.obs_hotkey_register_frontend(
            script_path(),
            player.name .. " Score Up",
            make_hotkey_callback(idx, 1)
        )
        local up = obs.obs_data_get_array(settings, "hotkey_player_up_" .. idx)
        obs.obs_hotkey_load(player.up_hotkey_id, up)
        obs.obs_data_array_release(up)

        -- Register DOWN hotkey
        player.down_hotkey_id = obs.obs_hotkey_register_frontend(
            script_path(),
            player.name .. " Score Down",
            make_hotkey_callback(idx, -1)
        )
        local down = obs.obs_data_get_array(settings, "hotkey_player_down_" .. idx)
        obs.obs_hotkey_load(player.down_hotkey_id, down)
        obs.obs_data_array_release(down)
    end
end

-- Script save: store hotkeys
function script_save(settings)
    for idx, player in ipairs(players) do
        local up = obs.obs_hotkey_save(player.up_hotkey_id)
        obs.obs_data_set_array(settings, "hotkey_player_up_" .. idx, up)
        obs.obs_data_array_release(up)

        local down = obs.obs_hotkey_save(player.down_hotkey_id)
        obs.obs_data_set_array(settings, "hotkey_player_down_" .. idx, down)
        obs.obs_data_array_release(down)
    end
end
