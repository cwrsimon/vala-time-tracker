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

	public DateCellRenderer(MainModel model) {
		GLib.Object ();
		this.editable = true;
		this.edited.connect ((path, new_text) => {
			//print("%s\n", path);
			//print("%s\n", new_text);

			Gtk.TreePath tPath = new Gtk.TreePath.from_string(path);

			//var model = view.get_model();
			TreeIter myiter;
			// TODO Was sinnvolleres finden!
			var base_iso = model.first_timestamp.format_iso8601();
			// 2020-04-28T21:09:13+02
			//print("%s\n", base_iso);
			var new_iso = base_iso.substring(0, 11) + new_text + ":00" + base_iso.substring(19);
			//print("%s\n", new_iso);
			var new_value = new DateTime.from_iso8601(new_iso, null);

			var res = model.get_iter(out myiter, tPath);
			if (!res) return;
			Value old_value = Value(typeof(DateTime));
			model.get_value(myiter, 0, out old_value);
			//print("%s\n", ((DateTime) old_value).format_iso8601());
			if (new_value != null) {
				model.set_value(myiter, 0, new_value);
			} else {
				model.set_value(myiter, 0, old_value);
			}
		});
	}

}