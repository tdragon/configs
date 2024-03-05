-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- For example, changing the color scheme:
config.color_scheme = "Catppuccin Mocha"
config.window_background_opacity = 0.90

config.font = wezterm.font("Hack Nerd Font", {bold=false, italic=false})
config.font_size = 15.0

--- Fix Alt keys for FI layout
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true

return config
