import re
from xkeysnail.transform import *

define_modmap({
    Key.CAPSLOCK: Key.ESC
})

define_keymap(re.compile("Firefox|Google-chrome|Brave-browser"), {
    K("Super-c"): K("C-c"),
    K("Super-x"): K("C-x"),
    K("Super-v"): K("C-v"),
    K("Super-f"): K("C-f"),
    K("Super-w"): K("C-w"),
    K("Super-a"): K("C-a"),
    K("Super-r"): K("C-r"),
    K("Super-z"): K("C-z"),
    K("Super-t"): K("C-t"),
    K("Super-Shift-z"): K("C-Shift-z"),
    K("Super-Shift-n"): K("C-Shift-n"),
    K("Super-M-i"): K("C-Shift-i"),
}, "Firefox, Chrome, and Brave")
# Someday maybe: scroll up and down with jk. Only if we can support in Mac too.

