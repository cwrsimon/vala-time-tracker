using Gtk;

public class MainView : Window {

	private Gtk.ListStore listmodel;

	private DateTime first_timestamp;
	private Gtk.Label date_label_content;

	// https://wiki.gnome.org/Projects/Vala/CustomWidgetSamples
	public MainView () {
		this.title = "Vala Time Tracker";
		set_default_size (1000, 400);
		var view = new TreeView ();
		Gtk.Label date_label_heading = new Gtk.Label("Date:");
		this.date_label_content = new Gtk.Label("");

		Gtk.Label target_label_heading = new Gtk.Label("Target:");
		var target_label_content = new Gtk.Label("8.0h");

		Gtk.Label remaining_label_heading = new Gtk.Label("Remaining:");
		var remaining_label_content = new Gtk.Label("8.0h");

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
	}

	public void add_entry() {
		TreeIter iter;
		this.listmodel.append (out iter);
		var now = new DateTime.now_local();
		this.listmodel.set_value (iter, 0, now);

		if (this.first_timestamp != null) return;
		this.first_timestamp = now;

		this.date_label_content.label = now.format("%x");

	}

	private void destroy_me() {
		this.hide();
	}

	private void setup_treeview (TreeView view) {

		/*
		 * Use ListStore to hold accountname, accounttype, balance and
		 * color attribute. For more info on how TreeView works take a
		 * look at the GTK+ API.
		 */

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


	}


}
