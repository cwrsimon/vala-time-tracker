using Gtk;

public class MainView : ApplicationWindow {

	private Label date_label_content;
	private Label remaining_label_content;
	private Label progress_label_content;

	private MainModel model;

	private File csv_directory;

	private uint timeout_handle;

	// https://developer.gnome.org/gnome-devel-demos/stable/beginner.vala.html.en
	// https://wiki.gnome.org/Projects/Vala/CustomWidgetSamples
	public MainView () {
		this.title = "Vala Time Tracker";
		set_default_size (600, 500);
		var view = new TreeView ();

		// add home directory
		init_csv_directory();
		
		this.model = new MainModel(csv_directory);
		view.set_model (this.model);

		setup_treeview (view);

		Gtk.Label date_label_heading = new Gtk.Label("Date:");
		date_label_heading.set_halign(Gtk.Align.END);

		this.date_label_content = new Gtk.Label("");
		this.date_label_content.set_halign(Gtk.Align.END);

		Gtk.Label target_label_heading = new Gtk.Label("Target:");
		target_label_heading.set_halign(Gtk.Align.END);

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

		ScrolledWindow scrolling_container = new ScrolledWindow(null, null);
		scrolling_container.add(view);

		var mainLayout = new Box(Gtk.Orientation.VERTICAL, 5);
		add (mainLayout);

		mainLayout.pack_start(header_bar, false, false, 5);
		mainLayout.pack_start(scrolling_container, true, true, 5);

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
				this.model.remove(ref iter);
			}
		});

		var save_button = new Button();
		save_button.set_label("Save");
		mainLayout.pack_start(save_button, false, false, 2);
		
		save_button.clicked.connect( () => {
			this.model.save_to_csv(this.model.csv_filename);
		});

		// Load existing data for today, if available
		this.model.load_from_csv(Utils.get_todays_date() + ".csv");

		// TODO FIXME
		if (this.model.first_timestamp != null) {
			this.date_label_content.label = this.model.first_timestamp.format("%x");
		}
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
		// How much time has passed since the last booking?
		// TODO Simplify
		TimeSpan sofarsogood = 0;
		TreeIter iter;
		DateTime last_booking = null;
		if (this.model.get_iter_first(out iter)) {
			DateTime prev_date = this.model.getDate(iter);
			var prev_was_pause = false;
			last_booking = prev_date;

			var isPause = this.model.getPause(iter);
			prev_was_pause = isPause;
			if (!isPause) {
				last_booking = prev_date;
			} else {
				prev_date = null;
				last_booking = null;
			}

			while (this.model.iter_next(ref iter)) {
				DateTime next_date = this.model.getDate(iter);
				var pause = this.model.getPause(iter);
				if (!pause) {
					last_booking = next_date;
				}
				if (prev_date != null && !prev_was_pause) {
					sofarsogood = sofarsogood + next_date.difference(prev_date);
				}
				prev_date = next_date;
				prev_was_pause = pause;
			}

		}
		this.progress_label_content.label = Utils.get_formatted_timespan(sofarsogood);
		var now = new DateTime.now();
		TimeSpan diff = 0;
		if (last_booking != null) {
			diff = now.difference(last_booking);
		}
		var remaining = this.model.target - diff - sofarsogood;
		this.remaining_label_content.label = Utils.get_formatted_timespan(remaining);
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

	private void init_csv_directory() {
		var home_dir = File.new_for_path (Environment.get_home_dir ());
		var csv_directory = home_dir.get_child(".vala-time-tracker");
		if (!csv_directory.query_exists()) {
			try {
			csv_directory.make_directory();
			} catch (Error e) {
				stderr.printf ("%s\n", e.message);
			}
		}
		this.csv_directory = csv_directory;
	}
}
