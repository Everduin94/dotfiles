local wezterm = require("wezterm")

local theme = wezterm.plugin.require("https://github.com/neapsix/wezterm").moon
-- NOTE: Cat
local custom = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
custom.background = "#181825"

-- custom.tab_bar.background = "#040404"
-- custom.tab_bar.inactive_tab.bg_color = "#0f0f0f"
-- custom.tab_bar.new_tab.bg_color = "#080808"

wezterm.on("toggle-highlight", function(window, pane)
	local colors = theme.colors()
	local overrides = window:get_config_overrides() or {}
	overrides.colors = colors
	if not overrides.window_background_opacity then
		overrides.window_background_opacity = 0.88
	elseif overrides.window_background_opacity == 0.88 then
		overrides.window_background_opacity = 0.82
	elseif overrides.window_background_opacity == 0.82 then
		overrides.window_background_opacity = 0.75
		overrides.colors.background = "#11111f"
		overrides.colors.tab_bar.background = "rgba(17, 17, 27, .85)"
		overrides.colors.tab_bar.inactive_tab.bg_color = "rgba(17, 17, 27, .85)"
		overrides.colors.tab_bar.active_tab.bg_color = "rgba(49, 50, 68, .9)"
		overrides.colors.tab_bar.new_tab.bg_color = "rgba(17, 17, 27, .85)"
	elseif overrides.window_background_opacity == 0.75 then
		overrides.window_background_opacity = 0.71
		overrides.colors.background = "#000000"
		overrides.colors.tab_bar.background = "rgba(17, 17, 27, .85)"
		overrides.colors.tab_bar.inactive_tab.bg_color = "rgba(17, 17, 27, .85)"
		overrides.colors.tab_bar.active_tab.bg_color = "rgba(49, 50, 68, .9)"
		overrides.colors.tab_bar.new_tab.bg_color = "rgba(17, 17, 27, .85)"
	elseif overrides.window_background_opacity == 0.71 then
		overrides.window_background_opacity = 0.95
	elseif overrides.window_background_opacity == 0.95 then
		overrides.window_background_opacity = 1
		overrides.colors.background = "#181825"
		overrides.colors.tab_bar.background = "rgba(17, 17, 27, .85)"
		overrides.colors.tab_bar.inactive_tab.bg_color = "rgba(17, 17, 27, .85)"
		overrides.colors.tab_bar.active_tab.bg_color = "rgba(49, 50, 68, .9)"
		overrides.colors.tab_bar.new_tab.bg_color = "rgba(17, 17, 27, .85)"
	else
		overrides.window_background_opacity = nil
	end
	window:set_config_overrides(overrides)
end)

local function tab_title(tab_info)
	local title = tab_info.tab_title
	-- if the tab title is explicitly set, take that
	if title and #title > 0 then
		return title
	end
	-- Otherwise, use the title from the active pane in that tab
	return tab_info.active_pane.title
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local title = tab_title(tab)
	local fg_color = "#CDD6F4"
	if title:lower():find("flotes") then
		fg_color = "#89b4fa"
	elseif title:lower():find("blog") then
		fg_color = "#f5c2e7"
	elseif title:lower():find("docs") then
		fg_color = "#96cdfb"
	elseif title:lower():find("platform") then
		fg_color = "#96cdfb"
	elseif title:lower():find("timer") then
		fg_color = "#a6e3a1"
	elseif title:lower():find("dotfiles") then
		fg_color = "#f9e2af"
	end

	return {
		{ Foreground = { Color = fg_color } },
		{ Text = " " .. title .. " " },
	}
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

local colors = theme.colors()

return {
	colors = colors,
	-- NOTE: Cat
	-- color_schemes = {
	-- 	["OLEDppuccin"] = custom,
	-- },
	-- color_scheme = "OLEDppuccin",

	-- window_padding = {
	-- 	left = 0,
	-- 	right = 0,
	-- 	top = 0,
	-- 	bottom = 0,
	-- },
	font = wezterm.font("GeistMono Nerd Font", { weight = "Bold" }),
	font_size = 14.0,

	font_rules = {
		{
			intensity = "Half",
			font = wezterm.font({
				family = "GeistMono Nerd Font",
				weight = "Regular", -- MUST be Regular. Not Bold.
			}, { foreground = "rgb(147, 153, 178)" }),
		},
	},

	bold_brightens_ansi_colors = "No",

	use_fancy_tab_bar = false, -- rounded corners, styled tabs
	hide_tab_bar_if_only_one_tab = false, -- cleaner look
	show_new_tab_button_in_tab_bar = true,

	adjust_window_size_when_changing_font_size = false,
	enable_tab_bar = true,
	-- macos_window_background_blur = 60, -- Max is about 60
	macos_window_background_blur = 45,
	window_background_opacity = 0.92,
	window_decorations = "RESIZE | MACOS_FORCE_ENABLE_SHADOW",
	window_background_image = "/Users/everduin/Downloads/uncharted_horizon_by_byrotek_deusrhv.png",
	-- This looks pretty interesting 👀
	-- window_background_gradient = {
	-- 	orientation = "Vertical",
	-- 	colors = {
	-- 		"#11111f",
	-- 		"#11111f",
	-- 		"#11111f",
	-- 		"#11111f",
	-- 		"#11111f",
	-- 		"#302b63",
	-- 		-- "#304048",
	-- 		-- "#442f3f",
	-- 	},
	--
	-- 	interpolation = "Linear",
	-- 	blend = "Rgb",
	-- },

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
		{
			key = "t",
			mods = "CMD|SHIFT",
			action = wezterm.action.PromptInputLine({
				description = "Rename current tab", -- text shown in the prompt
				action = wezterm.action_callback(function(window, pane, line)
					if line then
						window:active_tab():set_title(line)
					end
				end),
			}),
		},
	},
	window_frame = {
		border_left_width = "1px",
		border_right_width = "1px",
		border_top_height = "1px",
		border_bottom_height = "1px",

		-- color (use any hex)
		border_left_color = "#45475a",
		border_right_color = "#45475a",
		border_top_color = "#45475a",
		border_bottom_color = "#45475a",
	},
}
