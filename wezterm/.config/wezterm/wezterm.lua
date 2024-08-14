local wezterm = require("wezterm")

local custom = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
custom.background = "#181825"
-- custom.tab_bar.background = "#040404"
-- custom.tab_bar.inactive_tab.bg_color = "#0f0f0f"
-- custom.tab_bar.new_tab.bg_color = "#080808"

wezterm.on("toggle-highlight", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	if not overrides.window_background_opacity then
		overrides.window_background_opacity = 0.88
	elseif overrides.window_background_opacity == 0.88 then
		overrides.window_background_opacity = 0.82
	elseif overrides.window_background_opacity == 0.82 then
		overrides.window_background_opacity = 0.95
	elseif overrides.window_background_opacity == 0.95 then
		overrides.window_background_opacity = 1
	else
		overrides.window_background_opacity = nil
	end
	window:set_config_overrides(overrides)
end)

-- ZEN MODE
wezterm.on("user-var-changed", function(window, pane, name, value)
	local overrides = window:get_config_overrides() or {}
	if name == "ZEN_MODE" then
		local incremental = value:find("+")
		local number_value = tonumber(value)
		if incremental ~= nil then
			while number_value > 0 do
				window:perform_action(wezterm.action.IncreaseFontSize, pane)
				number_value = number_value - 1
			end
			-- overrides.enable_tab_bar = false
		elseif number_value < 0 then
			window:perform_action(wezterm.action.ResetFontSize, pane)
			overrides.font_size = nil
			-- overrides.enable_tab_bar = false
		else
			overrides.font_size = number_value
			-- overrides.enable_tab_bar = false
		end
	end
	window:set_config_overrides(overrides)
end)
-- END ZEN MODE

return {
	-- color_scheme = 'termnial.sexy',
	color_schemes = {
		["OLEDppuccin"] = custom,
	},
	color_scheme = "OLEDppuccin",

	-- More Spacing
	font = wezterm.font("GeistMono Nerd Font", { weight = "Bold" }),

	-- Vertically Tighter
	-- font = wezterm.font('CommitMono Nerd Font', { weight = 'Bold' }),

	-- Horizontally Wider
	-- font = wezterm.font('MonaspiceAr Nerd Font', { weight = 'Medium' }),

	-- 14 size + bold
	font_size = 14.0,

	adjust_window_size_when_changing_font_size = false,
	enable_tab_bar = false,
	macos_window_background_blur = 15,
	window_background_opacity = 0.92,

	-- window_background_image = '',
	-- window_background_image_hsb = {
	-- 	brightness = 0.01,
	-- 	hue = 1.0,
	-- 	saturation = 0.5,
	-- },
	-- window_background_opacity = 0.92,
	-- window_background_opacity = 0.84,
	-- window_background_opacity = 1.0,
	-- window_background_opacity = 0.78,
	-- window_background_opacity = 0.20,
	-- window_decorations = 'RESIZE | MACOS_FORCE_ENABLE_SHADOW',
	window_decorations = "RESIZE",
	-- window_decorations = 'MACOS_FORCE_ENABLE_SHADOW',
	mouse_bindings = {
		-- Ctrl-click will open the link under the mouse cursor
		{
			event = { Up = { streak = 1, button = "Left" } },
			mods = "CTRL",
			action = wezterm.action.OpenLinkAtMouseCursor,
		},
	},
	keys = {
		{
			key = "]",
			mods = "CTRL",
			action = wezterm.action.EmitEvent("toggle-highlight"),
		},
	},
}
