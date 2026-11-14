// GNOME Shell loads stylesheet.css next to this while the extension is
// enabled. The code follows GNOME's Dark Style switch, which only flips
// color-scheme: it reruns the theme for the new mode, through darkman when
// it's running (so its own state agrees), else theme.sh directly
import Gio from 'gi://Gio';
import GLib from 'gi://GLib';
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';

const RERUN = 'darkman set "$1" 2>/dev/null || exec "$HOME/.local/share/darkman/theme.sh" "$1"';

export default class DotfilesLook extends Extension {
    enable() {
        this._settings = new Gio.Settings({schema_id: 'org.gnome.desktop.interface'});
        this._changed = this._settings.connect('changed::color-scheme', () => this._follow());
    }

    disable() {
        this._settings.disconnect(this._changed);
        this._settings = null;
    }

    _follow() {
        const mode = this._settings.get_string('color-scheme') === 'prefer-dark' ? 'dark' : 'light';
        // theme.sh writes the mode first and sets color-scheme itself: a
        // change that already matches is our own echo, not the switch
        const file = GLib.build_filenamev([GLib.get_user_state_dir(), 'theme-mode']);
        try {
            const [, bytes] = GLib.file_get_contents(file);
            if (new TextDecoder().decode(bytes).trim() === mode)
                return;
        } catch (e) {
            // no theme run yet: follow anyway
        }
        GLib.spawn_async(null, ['sh', '-c', RERUN, 'sh', mode], null,
            GLib.SpawnFlags.SEARCH_PATH, null);
    }
}
