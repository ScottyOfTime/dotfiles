#!/usr/bin/env python3
"""Generate the palette files and ghostty, herdr and vim colours from oldschool.toml
(the generator is lib/colorscheme.py; this holds oldschool's mappings)."""

import sys
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "lib"))
from colorscheme import build

ROLES = ["bg", "panel", "surface", "fg", "dim", "comment", "ink", "line", "bright", "blue",
         "orange", "red", "yellow", "green", "cyan", "purple"]

# herdr's theme keys over a base theme
HERDR = {
    "panel_bg": "panel", "sidebar_bg": "bg", "active_row_bg": "surface",
    "selection_bg": "surface", "surface0": "panel", "surface1": "surface",
    "surface_dim": "bg", "overlay0": "dim", "overlay1": "dim", "text": "fg",
    "subtext0": "dim", "accent": "fg", "mauve": "purple", "green": "green",
    "yellow": "yellow", "red": "red", "peach": "orange", "blue": "blue",
    "teal": "cyan",
}

# (group, fg, bg, attr) as palette roles; "" leaves it unset
VIM = [
    ("Normal", "fg", "", ""), ("NormalFloat", "fg", "panel", ""),
    ("FloatBorder", "line", "panel", ""), ("Comment", "comment", "", "italic"),
    ("Constant", "purple", "", ""), ("String", "green", "", ""),
    ("Character", "green", "", ""), ("Number", "orange", "", ""),
    ("Boolean", "orange", "", ""), ("Identifier", "fg", "", ""),
    ("Function", "bright", "", ""), ("Statement", "orange", "", "bold"),
    ("Keyword", "orange", "", "bold"), ("Operator", "dim", "", ""),
    ("PreProc", "orange", "", ""), ("Include", "orange", "", ""),
    ("Type", "cyan", "", ""), ("Special", "yellow", "", ""),
    ("Delimiter", "dim", "", ""), ("Todo", "panel", "orange", "bold"),
    ("Underlined", "blue", "", "underline"), ("Error", "red", "", "bold"),
    ("ErrorMsg", "red", "", "bold"), ("WarningMsg", "orange", "", ""),
    ("Title", "bright", "", "bold"), ("Directory", "blue", "", ""),
    ("LineNr", "line", "", ""), ("CursorLineNr", "bright", "", "bold"),
    ("CursorLine", "", "panel", ""), ("ColorColumn", "", "panel", ""),
    ("SignColumn", "dim", "", ""), ("Visual", "", "surface", ""),
    ("Search", "panel", "orange", ""), ("IncSearch", "panel", "bright", ""),
    ("CurSearch", "panel", "bright", ""), ("MatchParen", "orange", "surface", "bold"),
    ("Pmenu", "fg", "panel", ""), ("PmenuSel", "panel", "fg", "bold"),
    ("PmenuSbar", "", "panel", ""), ("PmenuThumb", "", "dim", ""),
    ("StatusLine", "fg", "panel", ""), ("StatusLineNC", "dim", "panel", ""),
    ("TabLine", "dim", "panel", ""), ("TabLineSel", "panel", "fg", "bold"),
    ("TabLineFill", "", "panel", ""), ("VertSplit", "line", "", ""),
    ("WinSeparator", "line", "", ""), ("NonText", "line", "", ""),
    ("Whitespace", "line", "", ""), ("Folded", "dim", "panel", ""),
    ("DiffAdd", "green", "panel", ""), ("DiffChange", "yellow", "panel", ""),
    ("DiffDelete", "red", "panel", ""), ("DiffText", "panel", "yellow", ""),
    ("SpellBad", "red", "", "undercurl"), ("SpellCap", "orange", "", "undercurl"),
    ("WildMenu", "panel", "fg", ""), ("Question", "blue", "", ""),
    ("ModeMsg", "fg", "", "bold"), ("MoreMsg", "blue", "", ""),
    ("DiagnosticError", "red", "", ""), ("DiagnosticWarn", "orange", "", ""),
    ("DiagnosticInfo", "blue", "", ""), ("DiagnosticHint", "cyan", "", ""),
]

# airline: the text on the mode section, and each mode's colour
AIRLINE_TEXT = "panel"
AIRLINE_MODES = (("normal", "fg"), ("insert", "bright"), ("visual", "orange"),
                    ("replace", "red"), ("commandline", "fg"))

build(__file__, ROLES, HERDR, VIM, AIRLINE_TEXT, AIRLINE_MODES)
