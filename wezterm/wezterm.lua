local wezterm = require("wezterm")

wezterm.on("format-window-title", function(tab, pane, tabs, panes, config)
	return ""
end)

local config = wezterm.config_builder()

local function get_appearance()
	if wezterm.gui then
		return wezterm.gui.get_appearance()
	end
	return "Dark"
end

local function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "Solarized (dark) (terminal.sexy)"
	else
		return "Solarized (light) (terminal.sexy)"
	end
end

config.audible_bell = "Disabled"
config.color_scheme = scheme_for_appearance(get_appearance())
config.font = wezterm.font("GeistMono Nerd Font", { weight = "DemiBold" })
config.font_size = 14
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }
config.hide_tab_bar_if_only_one_tab = true
config.initial_cols = 100
config.initial_rows = 25
config.send_composed_key_when_left_alt_is_pressed = false

config.keys = {
	{
		key = "t",
		mods = "CMD",
		action = wezterm.action.DisableDefaultAssignment,
	},
}

return config
