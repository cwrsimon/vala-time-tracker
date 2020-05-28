using Gtk;
using Intl;

// based on https://wiki.gnome.org/Projects/Vala/StatusIcon
public class Main {

	class AppStatusIcon {
		private StatusIcon trayicon;
		private Gtk.Menu menuSystem;

		private MainView mainWindow;

		public AppStatusIcon() {

			Intl.setlocale(LocaleCategory.ALL, "");

			/* TODO Test on Gnome, KDE, etc. */
			trayicon = new StatusIcon.from_icon_name("appointment-new");
			trayicon.set_tooltip_text ("Tray");
			trayicon.set_visible(true);

			trayicon.activate.connect(show_window);

			create_menuSystem();
			trayicon.popup_menu.connect(menuSystem_popup);

			this.mainWindow = new MainView();


		}

		private void show_window() {
			mainWindow.show_all();
		}

		public void create_menuSystem() {
			menuSystem = new Gtk.Menu();
			var menuNew = new Gtk.MenuItem.with_label("New entry");
			menuNew.activate.connect( add_entry );
			menuSystem.append(menuNew);
			var menuAbout = new Gtk.MenuItem.with_label("About");
			menuAbout.activate.connect(about_clicked);
			menuSystem.append(menuAbout);
			var menuQuit = new Gtk.MenuItem.with_label("Quit");
			menuQuit.activate.connect(Gtk.main_quit);
			menuSystem.append(menuQuit);
			menuSystem.show_all();
		}

		/* Show popup menu on right button */
		private void menuSystem_popup(uint button, uint time) {
			menuSystem.popup(null, null, null, button, time);
		}

		private void about_clicked() {
			var about = new AboutDialog();
			about.set_version("0.0.1");
			about.set_program_name("vala-time-tracker");
			about.set_comments("A simple rudimentary GTK-based time tracker for Linux and Windows.");
			about.set_copyright("Christian Simon");
			about.run();
			about.hide();
		}

		private void add_entry() {
			this.mainWindow.add_entry();
		}

	}

	// https://stackoverflow.com/questions/5265167/pygtk-system-tray-icon-doesnt-work#5281034
	// Where to go from here
	// https://wiki.gnome.org/Projects/Vala/ListSample?highlight=%28%5CbVala%2FExamples%5Cb%29
	// https://wiki.gnome.org/Projects/Vala/GTKSample
	public static int main (string[] args) {
		Gtk.init(ref args);
		var app = new AppStatusIcon();
		Gtk.main();
		return 0;
	}
}
