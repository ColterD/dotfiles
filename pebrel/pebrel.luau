-- Pebrel configuration: Windows Terminal look (Fira Code Nerd Font; One Half Dark theme from the library).
-- Validate after edits:  pebrel config check      Restart Pebrel to apply.
-- Explicit keys in pebrel_settings.txt (Settings UI) override these defaults.
local pebrel = require 'pebrel'
local config = pebrel.config_builder()

config.font = {
    normal = { family = 'FiraCode Nerd Font', style = 'Regular' },
    size = 12.0,
}

-- Colors: One Half Dark is installed as a Pebrel library theme (~/.config/pebrel/themes/one-half-dark),
-- source ~/Documents/Projects/pebrel-themes/one-half-dark.json. Built-in themes override config.colors,
-- so pick it under Settings -> Theme instead of setting colors here.

return config
