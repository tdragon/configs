-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- For example, changing the color scheme:
-- config.color_scheme = "nord"
config.color_scheme = "Tokyo Night Moon"
-- config.color_scheme = "Catppuccin Mocha"

-- config.window_background_opacity = 0.90
-- config.window_background_image = wezterm.home_dir .. "/terminal-background.png"

config.font = wezterm.font_with_fallback({
	{ family = "Iosevka Term" },
	-- { family = "JetBrains Mono", weight = "Medium" },
	"Nerd Font Symbols",
	"Noto Color Emoji",
})

config.font_size = 18
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

return config
