#!/usr/bin/env python3
"""Generate the palette files and ghostty, herdr and vim colours from zine.toml
(the generator is lib/colorscheme.py; this holds zine's mappings)."""

import sys
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "lib"))
from colorscheme import build

ROLES = ["bg", "panel", "surface", "fg", "dim", "ink", "paper", "accent",
         "mustard", "sage", "teal", "blue", "rose", "plum", "red"]

# herdr's theme keys over a base theme
HERDR = {
    "panel_bg": "panel", "sidebar_bg": "bg", "active_row_bg": "surface",
    "selection_bg": "surface", "surface0": "panel", "surface1": "surface",
    "surface_dim": "bg", "overlay0": "dim", "overlay1": "dim", "text": "fg",
    "subtext0": "dim", "accent": "accent", "mauve": "plum", "green": "sage",
    "yellow": "mustard", "red": "red", "peach": "accent", "blue": "blue",
    "teal": "teal",
}

# (group, fg, bg, attr) as palette roles; "" leaves it unset
VIM = [
    ("Normal", "fg", "", ""), ("NormalFloat", "fg", "panel", ""),
    ("FloatBorder", "dim", "panel", ""), ("Comment", "dim", "", "italic"),
    ("Constant", "plum", "", ""), ("String", "sage", "", ""),
    ("Character", "sage", "", ""), ("Number", "plum", "", ""),
    ("Boolean", "plum", "", ""), ("Identifier", "fg", "", ""),
    ("Function", "blue", "", ""), ("Statement", "accent", "", "bold"),
    ("Keyword", "accent", "", "bold"), ("Operator", "fg", "", ""),
    ("PreProc", "rose", "", ""), ("Include", "rose", "", ""),
    ("Type", "teal", "", ""), ("Special", "mustard", "", ""),
    ("Delimiter", "dim", "", ""), ("Todo", "ink", "mustard", "bold"),
    ("Underlined", "blue", "", "underline"), ("Error", "red", "", "bold"),
    ("ErrorMsg", "red", "", "bold"), ("WarningMsg", "mustard", "", ""),
    ("Title", "accent", "", "bold"), ("Directory", "blue", "", ""),
    ("LineNr", "dim", "", ""), ("CursorLineNr", "accent", "", "bold"),
    ("CursorLine", "", "panel", ""), ("ColorColumn", "", "panel", ""),
    ("OverLength", "", "surface", ""),
    ("SignColumn", "dim", "", ""), ("Visual", "", "surface", ""),
    ("Search", "ink", "mustard", ""), ("IncSearch", "ink", "accent", ""),
    ("CurSearch", "ink", "accent", ""), ("MatchParen", "accent", "surface", "bold"),
    ("Pmenu", "fg", "panel", ""), ("PmenuSel", "ink", "accent", "bold"),
    ("PmenuSbar", "", "panel", ""), ("PmenuThumb", "", "dim", ""),
    ("StatusLine", "fg", "panel", ""), ("StatusLineNC", "dim", "panel", ""),
    ("TabLine", "dim", "panel", ""), ("TabLineSel", "ink", "accent", "bold"),
    ("TabLineFill", "", "panel", ""), ("VertSplit", "surface", "", ""),
    ("WinSeparator", "surface", "", ""), ("NonText", "surface", "", ""),
    ("Whitespace", "surface", "", ""), ("Folded", "dim", "panel", ""),
    ("DiffAdd", "sage", "panel", ""), ("DiffChange", "mustard", "panel", ""),
    ("DiffDelete", "red", "panel", ""), ("DiffText", "ink", "mustard", ""),
    ("SpellBad", "red", "", "undercurl"), ("SpellCap", "mustard", "", "undercurl"),
    ("WildMenu", "ink", "accent", ""), ("Question", "accent", "", ""),
    ("ModeMsg", "fg", "", "bold"), ("MoreMsg", "accent", "", ""),
    ("DiagnosticError", "red", "", ""), ("DiagnosticWarn", "mustard", "", ""),
    ("DiagnosticInfo", "blue", "", ""), ("DiagnosticHint", "teal", "", ""),
]

# airline: the text on the mode section, and each mode's colour
AIRLINE_TEXT = "ink"
AIRLINE_MODES = (("normal", "accent"), ("insert", "blue"), ("visual", "mustard"),
                    ("replace", "red"), ("commandline", "accent"))

build(__file__, ROLES, HERDR, VIM, AIRLINE_TEXT, AIRLINE_MODES)
