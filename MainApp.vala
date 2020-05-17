using Gtk;
// from https://wiki.gnome.org/Projects/Vala/StatusIcon
public class Main {

	class AppStatusIcon {
		private StatusIcon trayicon;
		private Gtk.Menu menuSystem;

		private MainView mainWindow;

		public AppStatusIcon() {
			/* Create tray icon */
			trayicon = new StatusIcon.from_icon_name("appointment-soon");
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

		/* Create menu for right button */
		public void create_menuSystem() {
			menuSystem = new Gtk.Menu();
			var menuNew = new ImageMenuItem.from_stock(Stock.NEW, null);
			menuNew.activate.connect( add_entry );
			menuSystem.append(menuNew);
			var menuAbout = new ImageMenuItem.from_stock(Stock.ABOUT, null);
			menuAbout.activate.connect(about_clicked);
			menuSystem.append(menuAbout);
			var menuQuit = new ImageMenuItem.from_stock(Stock.QUIT, null);
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
			about.set_version("0.0.0");
			about.set_program_name("Tray");
			about.set_comments("Tray utility");
			about.set_copyright("vala");
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
		var App = new AppStatusIcon();
		Gtk.main();
		return 0;
	}
}
