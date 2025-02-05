using Gtk;

// TODO Eine Gtk.Application verwenden
// und beim SessionManaget anmelden
// https://developer.gnome.org/gtk3/stable/GtkApplication.html#GtkApplication-query-end
public class TrackerTab : Gtk.Box {

	private Label date_label_content;
	private Label remaining_label_content;
	private Label progress_label_content;

	private MainModel model;

	private File csv_directory;

	private uint timeout_handle;


	// https://developer.gnome.org/gnome-devel-demos/stable/beginner.vala.html.en
	// https://wiki.gnome.org/Projects/Vala/CustomWidgetSamples
	public TrackerTab (string csv_file, File csv_directory) {
		//base(Gtk.Orientation.VERTICAL, 5);
		set_spacing(5);
		set_orientation(Gtk.Orientation.VERTICAL);

		var view = new TreeView ();
		this.model = new MainModel(csv_directory);
		view.set_model (this.model);

		setup_treeview (view);

		Gtk.Label date_label_heading = new Gtk.Label("Date:");
		date_label_heading.set_halign(Gtk.Align.END);

		this.date_label_content = new Gtk.Label("");
		this.date_label_content.set_halign(Gtk.Align.END);

		Gtk.Label target_label_heading = new Gtk.Label("Target:");
		target_label_heading.set_halign(Gtk.Align.END);

		Gtk.Label transportation_label_heading = new Gtk.Label("Type of Transportation:");
		transportation_label_heading.set_halign(Gtk.Align.END);
		
		var transportation_combo = new Gtk.ComboBoxText();
		transportation_combo.set_halign(Gtk.Align.END);
		transportation_combo.insert(0, "Public", "Public");
		transportation_combo.insert(1, "Car", "Car");
		transportation_combo.insert(2, "Bike", "Bike");
		transportation_combo.insert(3, "other", "other");
		//transportation_combo.s
		
		var target_hour = new Gtk.Entry();
		target_hour.set_width_chars(2);
		var target_separator = new Gtk.Label(":");
		var target_minutes = new Gtk.Entry();
		target_minutes.set_width_chars(2);

		Gtk.Box target_content = new Box(Gtk.Orientation.HORIZONTAL, 2);
		target_content.pack_start(target_hour, false, false, 2);
		target_content.pack_start(target_separator, false, false, 2);
		target_content.pack_start(target_minutes, false, false, 2);
		target_content.set_halign(Gtk.Align.END);

		Gtk.Label progress_label_heading = new Gtk.Label("Progress:");
		progress_label_heading.set_halign(Gtk.Align.END);

		this.progress_label_content = new Gtk.Label("");
		this.progress_label_content.set_halign(Gtk.Align.END);

		Gtk.Label remaining_label_heading = new Gtk.Label("Remaining:");
		remaining_label_heading.set_halign(Gtk.Align.END);

		this.remaining_label_content = new Gtk.Label("");
		remaining_label_content.set_halign(Gtk.Align.END);

		var header_bar = new Gtk.Grid();
		header_bar.set_column_homogeneous(true);
		header_bar.set_column_spacing(5);
		// TODO find a different way ...
		header_bar.set_margin_right(5);
		header_bar.attach(date_label_heading, 0, 0, 1, 1);
		header_bar.attach_next_to(date_label_content, date_label_heading, PositionType.RIGHT, 1, 1);
		header_bar.attach(target_label_heading, 0, 1, 1, 1);
		header_bar.attach_next_to(target_content, target_label_heading, PositionType.RIGHT, 1, 1);

		header_bar.attach_next_to(progress_label_heading, date_label_content, PositionType.RIGHT, 1, 1);
		header_bar.attach_next_to(progress_label_content, progress_label_heading, PositionType.RIGHT, 1, 1);
		header_bar.attach_next_to(remaining_label_heading, target_content, PositionType.RIGHT, 1, 1);
		header_bar.attach_next_to(remaining_label_content, remaining_label_heading, PositionType.RIGHT, 1, 1);
		header_bar.attach(transportation_label_heading, 0, 2, 1, 1);
		header_bar.attach_next_to(transportation_combo, transportation_label_heading, PositionType.RIGHT, 1, 1);

		ScrolledWindow scrolling_container = new ScrolledWindow(null, null);
		scrolling_container.add(view);

		pack_start(header_bar, false, false, 5);
		pack_start(scrolling_container, true, true, 5);


		var add_button = new Button();
		add_button.set_label("Add entry");
		pack_start(add_button, false, false, 2);

		add_button.clicked.connect( () => {
			add_entry();
		});

		var delete_button = new Button();
		delete_button.set_label("Delete Entry");
		pack_start(delete_button, false, false, 2);
		delete_button.clicked.connect( () => {
			var selection = view.get_selection();
			Gtk.TreeModel model;
			Gtk.TreeIter iter;
			if (selection.get_selected(out model, out iter)) {
				this.model.remove(ref iter);
			}
		});

		var save_button = new Button();
		save_button.set_label("Save");
		pack_start(save_button, false, false, 2);
		
		save_button.clicked.connect( () => {
			this.model.save_to_csv(this.model.csv_filename);
		});

		
		// Load existing data for today, if available

		// FIXME
		this.model.load_from_csv(csv_file);

		// TODO FIXME
		if (this.model.first_timestamp != null) {
			this.date_label_content.label = this.model.first_timestamp.format("%x");
		}
		transportation_combo.set_active_id(this.model.transportation);
		var formatted_target = Utils.get_formatted_timespan(this.model.target).split(":");
		target_hour.set_text(formatted_target[0]);
		target_minutes.set_text(formatted_target[1]);
		target_hour.changed.connect( () => {
			var new_value_hours = int64.parse(target_hour.text);
			var old_value_minutes = int64.parse(target_minutes.text);
			this.model.target = new_value_hours * TimeSpan.HOUR + old_value_minutes * TimeSpan.MINUTE ;
		});

		target_minutes.changed.connect( () => {
			var value_hours = int64.parse(target_hour.text);
			var value_minutes = int64.parse(target_minutes.text);
			this.model.target = value_hours * TimeSpan.HOUR + value_minutes * TimeSpan.MINUTE ;
		});
		// TODO Use widget synchronization one day...
		transportation_combo.changed.connect( () => {
			this.model.transportation = transportation_combo.get_active_text();
		});
		update();
	}

	public void add_entry() {
		this.model.add_now();
		if (this.timeout_handle == 0) {
			Timeout.add (1000, update);
		}
		// TODO Allow 12h format
		// FIXME??
		this.date_label_content.label = this.model.first_timestamp.format("%x");
	}

	private bool update() {
		this.model.update_progress();
		this.progress_label_content.label = Utils.get_formatted_timespan(this.model.progress);
		this.remaining_label_content.label = Utils.get_formatted_timespan(this.model.remaining);
		return true;
	}

	private void setup_treeview (TreeView view) {

		var date_cell = new DateCellRenderer (this.model);

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
			        this.model.set_value(myiter, 1, new_text);
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
			this.model.set_value (iter, 2, !toggle.active);
		});
		view.insert_column_with_attributes (-1, "Break", toggle, "active", 2);
		var col3 = view.get_column(2);
		col3.set_resizable(true);
		col3.set_min_width(100);
	}
}
