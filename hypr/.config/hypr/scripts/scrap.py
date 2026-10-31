#!/usr/bin/env python3
# Fuzzel can't draw shapes, so it runs with a transparent background and
# this draws a tilted paper scrap on the layer beneath it (fuzzel is on
# overlay, this is on top). launcher.sh starts it and kills it afterwards.
import json
import math
import os
import random
import subprocess

import cairo
import gi

gi.require_version("Gtk", "3.0")
gi.require_version("GtkLayerShell", "0.1")
from gi.repository import GLib, Gtk, GtkLayerShell

PAD = 18
JITTER = 12
TILT = 24
SHADOW = 7


def palette():
    mode = subprocess.run(["darkman", "get"], capture_output=True,
                          text=True).stdout.strip() or "dark"
    colours = {}
    with open(os.path.expanduser(f"~/.config/palette/{mode}.env")) as f:
        for line in f:
            key, _, value = line.strip().partition("=")
            if len(value) == 6 and all(c in "0123456789abcdef" for c in value):
                colours[key] = tuple(int(value[i:i + 2], 16) / 255 for i in (0, 2, 4))
    return colours


def hyprctl(*args):
    return json.loads(subprocess.run(["hyprctl", "-j", *args],
                                     capture_output=True, text=True).stdout)


def launcher():
    for mon in hyprctl("layers").values():
        for layer in mon["levels"].values():
            for surface in layer:
                if surface["namespace"] == "launcher":
                    return surface
    return None


class Scrap(Gtk.Window):
    def __init__(self, colours, rect, mon):
        super().__init__()
        self.colours, self.mon = colours, mon
        x, y, w, h = rect["x"] - mon["x"], rect["y"] - mon["y"], rect["w"], rect["h"]
        r = random.Random()
        j = lambda: r.uniform(-JITTER, JITTER)
        top, bottom = r.uniform(-TILT, TILT), r.uniform(-TILT, TILT)
        self.quad = [(x - PAD + j(), y - PAD + j() + top),
                     (x + w + PAD + j(), y - PAD + j() - top),
                     (x + w + PAD + j(), y + h + PAD + j() + bottom),
                     (x - PAD + j(), y + h + PAD + j() - bottom)]
        (lx, ly), (rx, ry) = self.quad[0], self.quad[1]
        along = r.uniform(0.3, 0.7)
        self.tape = (lx + (rx - lx) * along, ly + (ry - ly) * along, r.uniform(-0.12, 0.12))

        GtkLayerShell.init_for_window(self)
        GtkLayerShell.set_namespace(self, "scrap")
        GtkLayerShell.set_layer(self, GtkLayerShell.Layer.TOP)
        GtkLayerShell.set_exclusive_zone(self, -1)
        for edge in (GtkLayerShell.Edge.TOP, GtkLayerShell.Edge.BOTTOM,
                     GtkLayerShell.Edge.LEFT, GtkLayerShell.Edge.RIGHT):
            GtkLayerShell.set_anchor(self, edge, True)
        display = self.get_display()
        for i in range(display.get_n_monitors()):
            g = display.get_monitor(i).get_geometry()
            if (g.x, g.y) == (mon["x"], mon["y"]):
                GtkLayerShell.set_monitor(self, display.get_monitor(i))
        self.set_visual(self.get_screen().get_rgba_visual())
        self.set_app_paintable(True)
        self.connect("draw", self.draw)
        self.connect("realize", lambda w: w.input_shape_combine_region(cairo.Region()))
        self.show_all()

    def polygon(self, cr, points, offset=0):
        cr.move_to(points[0][0] + offset, points[0][1] + offset)
        for px, py in points[1:]:
            cr.line_to(px + offset, py + offset)
        cr.close_path()

    def draw(self, _win, cr):
        cr.set_operator(cairo.OPERATOR_CLEAR)
        cr.paint()
        cr.set_operator(cairo.OPERATOR_OVER)
        self.polygon(cr, self.quad, SHADOW)
        cr.set_source_rgb(*self.colours["ink"])
        cr.fill()
        self.polygon(cr, self.quad)
        cr.set_source_rgb(*self.colours["paper"])
        cr.fill()
        tx, ty, angle = self.tape
        cr.translate(tx, ty)
        cr.rotate(angle)
        cr.rectangle(-55, -14, 110, 28)
        cr.set_source_rgba(*self.colours["accent"], 0.75)
        cr.fill()


def wait_for_launcher(colours, tries=[0]):
    rect = launcher()
    if rect:
        mon = next(m for m in hyprctl("monitors") if m["focused"])
        Scrap(colours, rect, mon)
        return False
    tries[0] += 1
    if tries[0] > 100:
        Gtk.main_quit()
        return False
    return True


GLib.timeout_add(10, wait_for_launcher, palette())
Gtk.main()
