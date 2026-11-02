// GNOME Shell loads stylesheet.css next to this while the extension is
// enabled; there's nothing to run
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';

export default class DotfilesLook extends Extension {
    enable() {}
    disable() {}
}
