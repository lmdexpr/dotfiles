local wezterm = require 'wezterm'

local home = os.getenv("HOME")

return {
  font = wezterm.font("HackGen Console NF"),
  use_ime = true,
  enable_wayland = false,
  font_size = 14.0,
  color_scheme = "Hybrid",
  -- window_background_image = home .. "/.background.jpg",
  window_background_image_hsb = {
    brightness = 0.1,
    hue = 1.0,
    saturation = 1.0,
  },
  window_decorations = "RESIZE",
  window_background_opacity = 0.9,
  macos_window_background_blur = 10,
  hide_mouse_cursor_when_typing = false,
  show_new_tab_button_in_tab_bar = false,
  adjust_window_size_when_changing_font_size = false,
  leader = { key="b", mods="CTRL" },
  keys = {
    {key = "c", mods = "LEADER", action = wezterm.action {SpawnTab = "DefaultDomain"}},
    {key = "x", mods = "LEADER", action = wezterm.action {CloseCurrentTab = {confirm=true}}},

    {key = "b", mods = "LEADER", action = wezterm.action {ActivateTabRelative = -1}},
    {key = "n", mods = "LEADER", action = wezterm.action {ActivateTabRelative = 1}},

    {key = "1", mods = "LEADER", action = wezterm.action {ActivateTab = 0}},
    {key = "2", mods = "LEADER", action = wezterm.action {ActivateTab = 1}},
    {key = "3", mods = "LEADER", action = wezterm.action {ActivateTab = 2}},
    {key = "4", mods = "LEADER", action = wezterm.action {ActivateTab = 3}},
    {key = "5", mods = "LEADER", action = wezterm.action {ActivateTab = 4}},

    {key = "\\", mods = "LEADER", action = wezterm.action {SplitHorizontal = {domain = "CurrentPaneDomain"} }},
    {key = "-", mods = "LEADER", action = wezterm.action {SplitVertical = {domain = "CurrentPaneDomain"} }},

    {key = "q", mods = "LEADER", action = wezterm.action {CloseCurrentPane = {confirm=false}}},

    {key = "l", mods = "LEADER", action = wezterm.action {ActivatePaneDirection = "Right"}},
    {key = "h", mods = "LEADER", action = wezterm.action {ActivatePaneDirection = "Left"}},
    {key = "k", mods = "LEADER", action = wezterm.action {ActivatePaneDirection = "Up"}},
    {key = "j", mods = "LEADER", action = wezterm.action {ActivatePaneDirection = "Down"}},

    {key = "l", mods = "CMD|SHIFT", action = wezterm.action {AdjustPaneSize = { "Right", 1}}},
    {key = "h", mods = "CMD|SHIFT", action = wezterm.action {AdjustPaneSize = { "Left", 1}}},
    {key = "k", mods = "CMD|SHIFT", action = wezterm.action {AdjustPaneSize = { "Up", 1}}},
    {key = "j", mods = "CMD|SHIFT", action = wezterm.action {AdjustPaneSize = { "Down", 1}}},

    {key = "y", mods = "LEADER", action = wezterm.action.CopyTo 'ClipboardAndPrimarySelection'},
    {key = "p", mods = "LEADER", action = wezterm.action.PasteFrom 'Clipboard'},
  }
}
