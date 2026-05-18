local wezterm = require "wezterm"
local a = wezterm.action
local vivendi = wezterm.color.get_builtin_schemes()["Modus-Vivendi-Tinted"]
vivendi.ansi[8] = "#c6daff" -- fg-alt
vivendi.brights[1] = "#61647a" -- border
vivendi.brights[8] = "white"
return {
    adjust_window_size_when_changing_font_size = false,
    window_decorations = "TITLE | RESIZE",
    use_fancy_tab_bar = false,
    hide_tab_bar_if_only_one_tab = true,
    bold_brightens_ansi_colors = true,
    inactive_pane_hsb = { saturation = 1, brightness = 1 },
    bidi_enabled = true, -- a bit jank
    colors = vivendi,
    warn_about_missing_glyphs = false,
    unicode_version = 17,
    font_size = 13,
    font = wezterm.font_with_fallback {
        "iosevie", -- ~/Iosevka/private-build-plans.toml
        "Noto Sans",
        "Noto Sans CJK JP",
        "Amiri Typewriter",
        "Plangothic P1",
        "Plangothic P2",
        "Unifont",
        "Unifont CSUR",
        "Unifont Upper",
    },
    keys = {
        { key = "'", mods = "CTRL", action = a.SplitPane { direction = "Right" } },
        { key = ";", mods = "CTRL", action = a.SplitPane { direction = "Down" } },
        { key = "\\", mods = "CTRL", action = a.CloseCurrentPane { confirm = false } },
    },
}
