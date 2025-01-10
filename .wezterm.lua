local wezterm = require("wezterm")
local mux = wezterm.mux

-- This will hold the configuration.
local config = {
	default_workspace = "~",
	color_scheme = "Tokyo Night Moon",
	-- color_scheme = "Earthsong",

	window_background_opacity = 0.95,
	macos_window_background_blur = 10,
	inactive_pane_hsb = {
		saturation = 0.9,
		brightness = 0.7,
	},
	window_padding = {
		left = 3,
		right = 3,
		top = 3,
		bottom = 3,
	},
	window_frame = {
		font_size = 12,
	},
	command_palette_font_size = 16,
	window_decorations = "RESIZE",
	font = wezterm.font_with_fallback({
		{ family = "Iosevka Term" },
		-- { family = "JetBrains Mono", weight = "Medium" },
		"Nerd Font Symbols",
		"Noto Color Emoji",
	}),
	freetype_load_flags = "NO_HINTING",
	freetype_load_target = "Light",
	freetype_render_target = "HorizontalLcd",
	font_size = 15,
	front_end = "WebGpu",
	line_height = 1.0,
	cell_width = 1.0,

	hide_tab_bar_if_only_one_tab = false,
	tab_bar_at_bottom = true,
	use_fancy_tab_bar = true,

	--- Fix Alt keys for FI layout
	send_composed_key_when_right_alt_is_pressed = true,
	scrollback_lines = 5000,
	audible_bell = "Disabled",
	enable_scroll_bar = true,
	status_update_interval = 1000,
	leader = { key = "p", mods = "ALT", timeout_milliseconds = 1000 },
}

-- https://wezfurlong.org/wezterm/config/lua/gui-events/gui-startup.html
-- Maximize on start
wezterm.on("gui-startup", function(cmd)
	local _, _, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
resurrect.periodic_save()
resurrect.set_encryption({
	enable = true,
	method = "/opt/homebrew/bin/age",
	private_key = wezterm.home_dir .. "/.age/wezterm-key.txt",
	public_key = "age197epwatfx8pd96nhfpvesjwqkhvvuqhwytv9y6cf30h2xmuydvmsnse602",
})

local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
workspace_switcher.workspace_formatter = function(label)
	return wezterm.format({
		{ Attribute = { Italic = true } },
		{ Text = "󱂬 : " .. label },
	})
end

-- wezterm.on("gui-startup", resurrect.resurrect_on_gui_startup)

-- loads the state whenever I create a new workspace
wezterm.on("smart_workspace_switcher.workspace_switcher.created", function(window, path, label)
	local workspace_state = resurrect.workspace_state
	wezterm.log_info("Loading workspace " .. label)

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

config.keys = {
	{ key = "p", mods = "SHIFT|SUPER", action = wezterm.action.ActivateCommandPalette },
	{ key = "d", mods = "ALT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "v", mods = "ALT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "f", mods = "LEADER", action = wezterm.action.TogglePaneZoomState },
	{ key = "p", mods = "LEADER", action = wezterm.action.PaneSelect },
	{ key = "]", mods = "META", action = wezterm.action.RotatePanes("Clockwise") },
	{ key = "[", mods = "META", action = wezterm.action.RotatePanes("CounterClockwise") },
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
				id = string.match(id, "([^/]+)$")
				id = string.match(id, "(.+)%..+$")
				local state = resurrect.load_state(id, "workspace")
				local workspace_state = resurrect.workspace_state
				workspace_state.restore_workspace(state, {
					relative = true,
					restore_text = true,
					on_pane_restore = resurrect.tab_state.default_on_pane_restore,
				})
			end)
		end),
	},
}
workspace_switcher.zoxide_path = "/opt/homebrew/bin/zoxide"
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
local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")
bar.apply_to_config(config, {
	modules = {
		username = {
			enabled = false,
		},
		hostname = {
			enabled = false,
		},
	},
})

return config
