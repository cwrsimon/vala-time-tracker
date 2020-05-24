using Gtk;

public class MainModel : Gtk.ListStore {

	private DateTime _last_timestamp;
    public DateTime last_timestamp {
		get { return this._last_timestamp; }
		set { this._last_timestamp = value; }
    }

	private DateTime _first_timestamp;
    public DateTime first_timestamp {
		get { return this._first_timestamp; }
		set { this._first_timestamp = value; }
    }

	private TimeSpan _target = 8 * TimeSpan.HOUR;
    public TimeSpan target {
		// TODO implement a setter one day ...
        get { return this._target; }
    }
    


    public MainModel () {
		set_column_types( new Type[]{ typeof(DateTime), typeof(string), typeof(bool)  } ) ;
	}
	
	public static MainModel from_csv(string csv) {
		// TODO
		return new MainModel();
	}

	public string print_iter(TreeIter myiter) {
		Value date = Value(typeof(DateTime));
		get_value(myiter, 0, out date);
		Value desc = Value(typeof(string));
		get_value(myiter, 1, out desc);
		Value pause = Value(typeof(bool));
		get_value(myiter, 2, out pause);
		return "%s,%s,%d".printf(((DateTime) date).format_iso8601(),
		      ((string) desc), ((bool) pause) ? 1 : 0);

	}

	public void add_now() {
		TreeIter iter;
		append (out iter);
		var now_tmp = new DateTime.now_local();
		var now = new DateTime.local(now_tmp.get_year(), now_tmp.get_month(), now_tmp.get_day_of_month(),
		                             now_tmp.get_hour(), now_tmp.get_minute(), 0);
		set_value (iter, 0, now);

		this.last_timestamp = now;

		if (this.first_timestamp != null) return;
		this.first_timestamp = now;
	}

	public DateTime getDate(TreeIter iter) {
		Value v = Value(typeof(DateTime));
		get_value(iter, 0, out v);
		return (DateTime) v;
	}

	public bool getPause(TreeIter iter) {
		Value v = Value(typeof(DateTime));
		get_value(iter, 2, out v);
		return (bool) v;
	}
	
	
	public string csv_filename {
		owned get { return this._first_timestamp.format_iso8601().substring(0,10) + ".csv"; }
	}

	// TODO Add Timespan
	// TODO Add Date
	public void save_to_csv(string filename) {
		TreeIter iter;
		string csv_data = null;
		if (get_iter_first(out iter)) {
			csv_data =  print_iter(iter);
			while (iter_next(ref iter)) {
				csv_data = csv_data + "\n" + print_iter(iter);
			}
			csv_data = csv_data + "\n";
		}
		if (csv_data == null) return;
		try {
			var file = File.new_for_path (filename);
			// delete if file already exists
			if (file.query_exists ()) {
				file.delete ();
			}
			var dos = new DataOutputStream (file.create (FileCreateFlags.REPLACE_DESTINATION));
			uint8[] data = csv_data.data;
			long written = 0;
			while (written < data.length) {
				// sum of the bytes of 'text' that already have been written to the stream
				written += dos.write (data[written: data.length]);
			}
		} catch (Error e) {
			stderr.printf ("%s\n", e.message);
		}
	}

}