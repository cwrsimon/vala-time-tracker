using Gdk;
using Gtk;

class DateCellRenderer : Gtk.CellRendererText {

	private DateTime _datetime;

	public DateTime datetime {
		get {return this._datetime;}
		set {
			this._datetime = value;
			this.text = value.format("%H:%M");
		}
	}

	public DateCellRenderer() {
		GLib.Object ();
	}

}