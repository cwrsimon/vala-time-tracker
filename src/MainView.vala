using Gtk;

// TODO Hier weitermachen:
//https://wiki.gnome.org/Projects/Vala/GTKSample#Vala_GTK.2B-_Examples

// TODO Eine Gtk.Application verwenden
// und beim SessionManaget anmelden
// https://developer.gnome.org/gtk3/stable/GtkApplication.html#GtkApplication-query-end
public class MainView : ApplicationWindow {
	private File csv_directory;

	private uint timeout_handle;

	private Main.AppStatusIcon icon;
	private TrackerTab todaysTab;
	private Notebook notebook_container;

	// https://developer.gnome.org/gnome-devel-demos/stable/beginner.vala.html.en
	// https://wiki.gnome.org/Projects/Vala/CustomWidgetSamples
	public MainView () {
		this.title = "Vala Time Tracker";
		set_default_size (600, 500);

		this.icon = new Main.AppStatusIcon(this);

		// add home directory
		init_csv_directory();
		
		this.notebook_container = new Notebook();

		this.todaysTab = new TrackerTab(Utils.get_todays_date() + ".csv", this.csv_directory);

		notebook_container.append_page(todaysTab, new Label("Today"));

		this.window_state_event.connect ( state_changed_proc );
		this.delete_event.connect (hide_on_delete );

		var menu_bar = new Gtk.MenuBar();

		var bla = new Gtk.MenuItem.with_label("Open CSV");
		bla.activate.connect(open_csv);

		var balance = new Gtk.MenuItem.with_label("Show Balance");
		balance.activate.connect(show_balance);

		var file = new Gtk.MenuItem.with_label("File");
		var menu = new Gtk.Menu();
		var quit = new Gtk.MenuItem.with_label("Quit");
		quit.activate.connect(Gtk.main_quit);

		menu.append(bla);
		menu.append(balance);
		menu.append(quit);

		file.set_submenu(menu);
		menu_bar.append(file);
		
		var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 1);
		box.pack_start(menu_bar, false, false, 0);
		box.pack_start(notebook_container);

		add (box);

	}

	private async void show_balance() {
		var yesterday_layout = new Box(Gtk.Orientation.VERTICAL, 5);
		notebook_container.append_page(yesterday_layout, new Label("Past days"));

		var text_view = new TextView();

		ScrolledWindow scrolling_container_text = new ScrolledWindow(null, null);
		scrolling_container_text.add(text_view);
		
		yesterday_layout.add(new Label("Your work balance"));
		yesterday_layout.pack_start(scrolling_container_text, true, true, 5);

			text_view.get_buffer().text = "";
			// TODO Brauchen wir hier einen StringBuilder, o.ä.??
			var new_content = "";
			var todays_file = Utils.get_todays_date() + ".csv";
			TimeSpan balance = 0;
			try {
			var enumerator = this.csv_directory.enumerate_children("standard::*,owner:GFile:user", FileQueryInfoFlags.NOFOLLOW_SYMLINKS);
			FileInfo info = null;
			while (((info = enumerator.next_file ()) != null)) {
			if (info.get_file_type () == FileType.REGULAR) {
				var filename = info.get_name();
				if (filename == todays_file) {
					continue;
				}
				print ("%s\n", filename);
				MainModel newModel = new MainModel(this.csv_directory);
				newModel.load_from_csv(info.get_name ());
				newModel.update_progress();
				var progress_formatted = Utils.get_formatted_timespan(newModel.progress); 
				print ("Progress: %s\n", progress_formatted);
				var remaining_formatted = Utils.get_formatted_timespan(newModel.remaining);
				print ("Remaining: %s\n", remaining_formatted);
				balance = balance + (newModel.remaining * -1);
				new_content = new_content + filename + "\t" + progress_formatted + "\t" + remaining_formatted + "\n";
			}
			} } catch (Error e) {
				print("Error: %s\n", e.message);
			}
			new_content = new_content + "\nWork balance: " + Utils.get_formatted_timespan(balance); 
			print("Work balance: %s\n", Utils.get_formatted_timespan(balance));
			text_view.get_buffer().text = new_content;
		notebook_container.show_all();
	}
	
	private bool state_changed_proc ( Gtk.Widget widget, Gdk.EventWindowState  type) {
		print("Hide Proc %s, %s\n", type.changed_mask.to_string(), 
		type.new_window_state.to_string());
		if (type.changed_mask == 130 && type.new_window_state == 2) {
			hide();
		} 
		return true;
	}

	private async void open_csv() {
		var file_chooser = new FileChooserDialog ("Open CSV File", this,
				FileChooserAction.OPEN,
				"_Cancel", 
				ResponseType.CANCEL, "_Open", ResponseType.ACCEPT);
		var response = file_chooser.run();
		if (response == ResponseType.ACCEPT) {
			var file = file_chooser.get_file();
			var filename = file.get_basename();
			var parent_dir = file.get_parent();
			print("%s,%s", filename, parent_dir.get_path());
			var new_tab = new TrackerTab(filename, parent_dir);
			print("new Tab");
			this.notebook_container.append_page(new_tab, new Label(filename));
			this.notebook_container.show_all();
		}
		file_chooser.destroy ();
	}

	public void add_entry() {
		todaysTab.add_entry();
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
