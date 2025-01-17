
```toml
#[general]
#import = [
#    "~/.config/alacritty/themes/themes/alabaster.toml"
#]

[colors]
draw_bold_text_with_bright_colors = true

[colors.bright]
black = "#555555"
blue = "#5555ff"
cyan = "#55ffff"
green = "#55ff55"
magenta = "#ff55ff"
red = "#ff5555"
white = "#ffffff"
yellow = "#ffff55"

[colors.normal]
black = "#000000"
blue = "#0000bb"
cyan = "#00bbbb"
green = "#00bb00"
magenta = "#bb00bb"
red = "#bb0000"
white = "#bbbbbb"
yellow = "#bbbb00"

[colors.primary]
background = "#000000"
bright_foreground = "#555555"
dim_foreground = "#bbbbbb"
foreground = "#bbbbbb"

[env]
TERM = "xterm-256color"

[font]
size = 19.0

[font.bold]
family = "Iosevka Fixed"
style = "Regular"

[font.bold_italic]
family = "Iosevka Fixed"
style = "Regular"

[font.italic]
family = "Iosevka Fixed"
style = "Regular"

[font.normal]
family = "Iosevka Fixed"
style = "Regular"

[[keyboard.bindings]]
action = "Togglefullscreen"
key = "F11"

[[mouse.bindings]]
action = "PasteSelection"
mouse = "Right"

[selection]
save_to_clipboard = true

[window]
resize_increments = true
startup_mode = "Windowed"
title = "Alacritty"

[window.class]
general = "Alacritty"
instance = "Alacritty"

[window.dimensions]
columns = 160
lines = 50

[window.padding]
x = 6
y = 6

[hints]
enabled = []

#[bell]
#animation = "EaseOutQuad"
#duration = 50
```
