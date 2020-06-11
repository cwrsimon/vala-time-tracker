
public class MyApplication : Gtk.Application {

	private Gtk.ApplicationWindow window;

	public MyApplication () {
		Object(application_id: "testing.my.application",
				flags: ApplicationFlags.FLAGS_NONE);
		
	}

	private void do_you_want_to_save() {
		var messagedialog = new Gtk.MessageDialog (this.window,
			Gtk.DialogFlags.MODAL,
			Gtk.MessageType.WARNING,
			Gtk.ButtonsType.OK_CANCEL,
			"This action will cause the universe to stop existing.");

//messagedialog.response.connect (dialog_response);
messagedialog.show ();
	}

	protected override void activate () {
		// Create the window of this application and show it
		this.window = new Gtk.ApplicationWindow (this);
		window.set_default_size (400, 400);
		window.title = "My Gtk.Application";

		Gtk.Label label = new Gtk.Label ("Hello, GTK");
		var delete_button = new Gtk.Button();
		delete_button.set_label("Delete Entry");
		delete_button.clicked.connect( do_you_want_to_save);


		window.add (delete_button);
		window.show_all ();

		this.register_session = true;
		this.query_end.connect( do_you_want_to_save );
	}

	public static int main (string[] args) {
		MyApplication app = new MyApplication ();
		return app.run (args);
	}
}