local wezterm = require 'wezterm';

local home = os.getenv("HOME")

return {
  font = wezterm.font("Ricty for Powerline"),
  use_ime = true,
  font_size = 16.0,
  color_scheme = 'Hybrid',
  window_background_image = home .. "/.background.jpg",
  window_background_image_hsb = {
    brightness = 0.2,
    hue = 1.0,
    saturation = 1.0,
  },
  adjust_window_size_when_changing_font_size = false,
  leader = { key="b", mods="CTRL" },
  keys = {
    {key = "c", mods = "LEADER", action = wezterm.action {SpawnTab = "CurrentPaneDomain"}},
    {key = "x", mods = "LEADER", action = wezterm.action {CloseCurrentTab = {confirm=true}}},
    {key = "p", mods = "LEADER", action = wezterm.action {ActivateTabRelative = -1}},
    {key = "n", mods = "LEADER", action = wezterm.action {ActivateTabRelative = 1}},
    {key = "1", mods = "LEADER", action = wezterm.action {ActivateTab = 0}},
    {key = "2", mods = "LEADER", action = wezterm.action {ActivateTab = 1}},
    {key = "3", mods = "LEADER", action = wezterm.action {ActivateTab = 2}},
    {key = "4", mods = "LEADER", action = wezterm.action {ActivateTab = 3}},
    {key = "5", mods = "LEADER", action = wezterm.action {ActivateTab = 4}},

    {key = "|", mods = "LEADER", action = wezterm.action {SplitHorizontal = {domain = "CurrentPaneDomain"} }},
    {key = "-", mods = "LEADER", action = wezterm.action {SplitVertical = {domain = "CurrentPaneDomain"} }},
    {key = "*", mods = "LEADER", action = wezterm.action {CloseCurrentPane = {confirm=false}}},
    {key = "l", mods = "LEADER", action = wezterm.action {ActivatePaneDirection = "Right"}},
    {key = "h", mods = "LEADER", action = wezterm.action {ActivatePaneDirection = "Left"}},
    {key = "k", mods = "LEADER", action = wezterm.action {ActivatePaneDirection = "Up"}},
    {key = "j", mods = "LEADER", action = wezterm.action {ActivatePaneDirection = "Down"}},
    {key = "l", mods = "LEADER|SHIFT", action = wezterm.action {AdjustPaneSize = { "Right", 1}}},
    {key = "h", mods = "LEADER|SHIFT", action = wezterm.action {AdjustPaneSize = { "Left", 1}}},
    {key = "k", mods = "LEADER|SHIFT", action = wezterm.action {AdjustPaneSize = { "Up", 1}}},
    {key = "j", mods = "LEADER|SHIFT", action = wezterm.action {AdjustPaneSize = { "Down", 1}}},
  }
}
