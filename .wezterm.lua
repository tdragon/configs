-- Pull in the wezterm API
local wezterm = require("wezterm")
wezterm.log_info("The config was reloaded for this window! " .. wezterm.home_dir)

-- This will hold the configuration.
local config = wezterm.config_builder()

-- For example, changing the color scheme:
-- config.color_scheme = "nord"
config.color_scheme = "Tokyo Night Moon"
-- config.color_scheme = "Catppuccin Mocha"

config.window_background_opacity = 1.0
-- config.macos_window_background_blur = 10
-- config.window_background_image = wezterm.home_dir .. "/terminal-background.png"

config.font = wezterm.font_with_fallback({
	{ family = "Iosevka Term" },
	-- { family = "JetBrains Mono", weight = "Medium" },
	"Nerd Font Symbols",
	"Noto Color Emoji",
})
config.freetype_load_flags = "NO_HINTING"
config.font_size = 15
config.front_end = "WebGpu"
config.line_height = 1.0
-- config.freetype_load_target = "Light"
-- config.freetype_render_target = "HorizontalLcd"
config.cell_width = 1.0

config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false

--- Fix Alt keys for FI layout
--config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true

-- https://wezfurlong.org/wezterm/config/lua/gui-events/gui-startup.html
-- Maximize on start
local mux = wezterm.mux

wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

config.window_decorations = "RESIZE"

local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
resurrect.periodic_save()
resurrect.set_encryption({
	enable = true,
	method = "age",
	private_key = wezterm.home_dir .. "/wezterm-key.txt",
	public_key = "age197epwatfx8pd96nhfpvesjwqkhvvuqhwytv9y6cf30h2xmuydvmsnse602",
})

local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
-- workspace_switcher.workspace_formatter = function(label)
-- 	return wezterm.format({
-- 		{ Attribute = { Italic = true } },
-- 		{ Foreground = { Color = colors.colors.ansi[3] } },
-- 		{ Background = { Color = colors.colors.background } },
-- 		{ Text = "󱂬 : " .. label },
-- 	})
-- end

-- loads the state whenever I create a new workspace
wezterm.on("smart_workspace_switcher.workspace_switcher.created", function(window, path, label)
	local workspace_state = resurrect.workspace_state

	workspace_state.restore_workspace(resurrect.load_state(label, "workspace"), {
		window = window,
		relative = true,
		restore_text = true,
		on_pane_restore = resurrect.tab_state.default_on_pane_restore,
	})
end)

-- Saves the state whenever I select a workspace
wezterm.on("smart_workspace_switcher.workspace_switcher.selected", function(window, path, label)
	local workspace_state = resurrect.workspace_state
	resurrect.save_state(workspace_state.get_workspace_state())
end)

config.leader = { key = "p", mods = "ALT", timeout_milliseconds = 1000 }
config.keys = {
	{ key = "v", mods = "ALT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "d", mods = "ALT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "f", mods = "LEADER", action = wezterm.action.TogglePaneZoomState },
	{ key = "p", mods = "LEADER", action = wezterm.action.PaneSelect },
	{ key = "]", mods = "META", action = wezterm.action.RotatePanes("Clockwise") },
	{ key = "[", mods = "META", action = wezterm.action.RotatePanes("CounterClockwise") },
	-- Workspaces
	{
		key = "s",
		mods = "LEADER",
		action = workspace_switcher.switch_workspace(),
	},
	{
		key = "S",
		mods = "LEADER",
		action = workspace_switcher.switch_to_prev_workspace(),
	},
	-- Resurrect mapping
	{
		key = "t",
		mods = "ALT",
		action = resurrect.tab_state.save_tab_action(),
	},
	{
		key = "s",
		mods = "ALT",
		action = wezterm.action_callback(function(win, pane)
			resurrect.save_state(resurrect.workspace_state.get_workspace_state())
			resurrect.window_state.save_window_action()
		end),
	},
	{
		key = "r",
		mods = "ALT",
		action = wezterm.action_callback(function(win, pane)
			resurrect.fuzzy_load(win, pane, function(id, label)
				local type = string.match(id, "^([^/]+)") -- match before '/'
				id = string.match(id, "([^/]+)$") -- match after '/'
				id = string.match(id, "(.+)%..+$") -- remove file extention
				local opts = {
					relative = true,
					restore_text = true,
					on_pane_restore = resurrect.tab_state.default_on_pane_restore,
				}
				if type == "workspace" then
					local state = resurrect.load_state(id, "workspace")
					resurrect.workspace_state.restore_workspace(state, opts)
				elseif type == "window" then
					local state = resurrect.load_state(id, "window")
					resurrect.window_state.restore_window(pane:window(), state, opts)
				elseif type == "tab" then
					local state = resurrect.load_state(id, "tab")
					resurrect.tab_state.restore_tab(pane:tab(), state, opts)
				end
			end)
		end),
	},
}
workspace_switcher.apply_to_config(config)

local smart_splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")
smart_splits.apply_to_config(config, {
	direction_keys = { "h", "j", "k", "l" },
	modifiers = {
		move = "ALT",
		resize = "ALT|SHIFT",
	},
})
smart_splits.apply_to_config(config, {
	direction_keys = { "LeftArrow", "DownArrow", "UpArrow", "RightArrow" },
	modifiers = {
		move = "ALT",
		resize = "ALT|SHIFT",
	},
})

return config
