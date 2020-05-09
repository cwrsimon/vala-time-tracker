using Gtk;

public class MainView : Window {

	private Gtk.ListStore listmodel;

	private DateTime first_timestamp;
	private DateTime last_timestamp;
	private Label date_label_content;
	private Label remaining_label_content;
	private TimeSpan target = 8 * TimeSpan.HOUR;

	// https://developer.gnome.org/gnome-devel-demos/stable/beginner.vala.html.en
	// https://wiki.gnome.org/Projects/Vala/CustomWidgetSamples
	public MainView () {
		this.title = "Vala Time Tracker";
		set_default_size (1000, 400);
		var view = new TreeView ();
		Gtk.Label date_label_heading = new Gtk.Label("Date:");
		this.date_label_content = new Gtk.Label("");

		Gtk.Label target_label_heading = new Gtk.Label("Target:");
		var target_label_content = new Gtk.Label(get_formatted_timespan(target));

		Gtk.Label remaining_label_heading = new Gtk.Label("Remaining:");
		this.remaining_label_content = new Gtk.Label("8.0h");

		var header_bar = new Box(Gtk.Orientation.HORIZONTAL, 6);
		header_bar.pack_start(date_label_heading, true, true, 2);
		header_bar.pack_start(date_label_content, true, true, 2);
		header_bar.pack_start(target_label_heading, true, true, 2);
		header_bar.pack_start(target_label_content, true, true, 2);
		header_bar.pack_start(remaining_label_heading, true, true, 2);
		header_bar.pack_start(remaining_label_content, true, true, 2);

		setup_treeview (view);

		ScrolledWindow scrolling_container = new ScrolledWindow(null, null);
		scrolling_container.add(view);

		var mainLayout = new Box(Gtk.Orientation.VERTICAL, 6);
		add (mainLayout);

		mainLayout.pack_start(header_bar, false, false, 2);
		mainLayout.pack_start(scrolling_container, true, true,2);

		this.delete_event.connect (hide_on_delete );

		var add_button = new Button();
		add_button.set_label("Add entry");
		mainLayout.pack_start(add_button, false, false, 2);

		add_button.clicked.connect( () => {

			add_entry();
		});

		var delete_button = new Button();
		delete_button.set_label("Delete Entry");
		mainLayout.pack_start(delete_button, false, false, 2);
		delete_button.clicked.connect( () => {
			var selection = view.get_selection();
			Gtk.TreeModel model;
			Gtk.TreeIter iter;
			if (selection.get_selected(out model, out iter)) {
			        this.listmodel.remove(ref iter);
			}
		});

		var save_button = new Button();
		save_button.set_label("Save");
		mainLayout.pack_start(save_button, false, false, 2);
		//
		save_button.clicked.connect( () => {
			TreeIter iter;
			if (listmodel.get_iter_first(out iter)) {

			        print_iter(iter);
			        while (listmodel.iter_next(ref iter)) {

			                print_iter(iter);
				}

			}
		});


	}

	private DateTime getDate(TreeIter iter) {
		Value v = Value(typeof(DateTime));
		listmodel.get_value(iter, 0, out v);
		return (DateTime) v;
	}

	private bool getPause(TreeIter iter) {
		Value v = Value(typeof(DateTime));
		listmodel.get_value(iter, 2, out v);
		return (bool) v;
	}

	private bool update() {
		// How much time has passed since the last booking?
		// FIXME
		TimeSpan sofarsogood = 0;
		TreeIter iter;
		DateTime last_booking = null;
		if (listmodel.get_iter_first(out iter)) {
			DateTime prev_date = getDate(iter);
			var prev_was_pause = false;
			last_booking = prev_date;

			var isPause = getPause(iter);
			prev_was_pause = isPause;
			if (!isPause) {
				last_booking = prev_date;
			} else {
				prev_date = null;
				last_booking = null;
			}


			while (listmodel.iter_next(ref iter)) {
				DateTime next_date = getDate(iter);
				var pause = getPause(iter);
				if (!pause) {
					last_booking = next_date;
				}
				// TODO Wenn der Vorgänger eine Pause war, dürfen wir nicht
				// hinzuaddieren!
				if (prev_date != null && !prev_was_pause) {
					sofarsogood = sofarsogood + next_date.difference(prev_date);
				}
				prev_date = next_date;
				prev_was_pause = pause;
			}

		}
		print("So far so good:%s\n", get_formatted_timespan(sofarsogood));
		//var last_booking = this.last_timestamp;
		var now = new DateTime.now();
		var diff = 0;
		if (last_booking != null) {
			now.difference(last_booking);
		}
		var remaining = this.target - diff - sofarsogood;
		this.remaining_label_content.label = get_formatted_timespan(remaining);
		return true;
	}

	private string get_formatted_timespan(TimeSpan remaining) {
		var remaining_hours = (remaining / TimeSpan.HOUR).abs();
		var remaining_minutes = ((remaining - (TimeSpan.HOUR * remaining_hours)) / TimeSpan.MINUTE).abs();
		var remaining_seconds = (remaining
		                         - (TimeSpan.HOUR * remaining_hours)
		                         - (TimeSpan.MINUTE * remaining_minutes)) / 1000 / 1000;

		return "%s' %s'' %s".
		       printf(remaining_hours.to_string(), remaining_minutes.to_string(), remaining_seconds.to_string());
	}

	public void print_iter(TreeIter myiter) {
		Value date = Value(typeof(DateTime));
		listmodel.get_value(myiter, 0, out date);
		Value desc = Value(typeof(string));
		listmodel.get_value(myiter, 1, out desc);
		Value pause = Value(typeof(bool));
		listmodel.get_value(myiter, 2, out pause);
		print("%s,%s,%d\n", ((DateTime) date).format_iso8601(),
		      ((string) desc), ((bool) pause) ? 1 : 0);
	}

	public void add_entry() {
		TreeIter iter;
		this.listmodel.append (out iter);
		var now = new DateTime.now_local();
		this.listmodel.set_value (iter, 0, now);

		this.last_timestamp = now;

		if (this.first_timestamp != null) return;
		this.first_timestamp = now;
		Timeout.add (1000, update);

		this.date_label_content.label = now.format("%x");

	}

	private void destroy_me() {
		this.hide();
	}

	private void setup_treeview (TreeView view) {

		this.listmodel = new Gtk.ListStore (3, typeof (DateTime), typeof (string),
		                                    typeof (bool));
		view.set_model (listmodel);

		var date_cell = new DateCellRenderer ();
		date_cell.editable = true;
		date_cell.edited.connect ((path, new_text) => {
			print("%s\n", path);
			print("%s\n", new_text);

			Gtk.TreePath tPath = new Gtk.TreePath.from_string(path);

			var model = view.get_model();
			TreeIter myiter;
			// TODO Was sinnvolleres finden!
			var base_iso = this.first_timestamp.format_iso8601();
			// 2020-04-28T21:09:13+02
			print("%s\n", base_iso);
			var new_iso = base_iso.substring(0, 11) + new_text + ":00" + base_iso.substring(19);
			print("%s\n", new_iso);
			var new_value = new DateTime.from_iso8601(new_iso, null);

			var res = model.get_iter(out myiter, tPath);
			if (!res) return;
			Value old_value = Value(typeof(DateTime));
			listmodel.get_value(myiter, 0, out old_value);
			print("%s\n", ((DateTime) old_value).format_iso8601());
			if (new_value != null) {
			        listmodel.set_value(myiter, 0, new_value);
			} else {
			        listmodel.set_value(myiter, 0, old_value);
			}
		});

		view.insert_column_with_attributes (-1, "Timestamp", date_cell, "datetime", 0);
		var col1 = view.get_column(0);
		col1.resizable = true;
		col1.set_min_width(150);

		var cell = new CellRendererText ();
		cell.set ("foreground_set", true);
		cell.editable = true;
		cell.edited.connect ((path, new_text) => {

			Gtk.TreePath tPath = new Gtk.TreePath.from_string(path);
			var model = view.get_model();
			TreeIter myiter;

			var res = model.get_iter(out myiter, tPath);
			if (res == true) {
			        listmodel.set_value(myiter, 1, new_text);
			}
		});
		view.insert_column_with_attributes (-1, "Project", cell, "text", 1);

		var col2 = view.get_column(1);
		col2.set_resizable(true);
		col2.set_expand(true);
		//col2.set_min_width(500);

		var toggle = new CellRendererToggle ();
		toggle.toggled.connect ((toggle, path) => {
			var tree_path = new TreePath.from_string (path);
			var model = view.get_model();

			TreeIter iter;
			model.get_iter (out iter, tree_path);
			listmodel.set_value (iter, 2, !toggle.active);
		});
		view.insert_column_with_attributes (-1, "Pause", toggle, "active", 2);
		var col3 = view.get_column(2);
		col3.set_resizable(true);
		col3.set_min_width(100);

		TreeIter iter;
		listmodel.append(out iter);
		listmodel.set(iter, 0, new DateTime.now_local(), 1, "Bla", 2, false );
	}


}
