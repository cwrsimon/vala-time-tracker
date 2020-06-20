using Gtk;

public class MainModel : Gtk.ListStore {

	private File csv_directory;

	public TimeSpan remaining {get; set; }
	public TimeSpan progress {get; set; }

	private string _transportation = "other";
	public string transportation {
		get { return this._transportation; }
		set { this._transportation = value; }
	}

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

	// by default, we must work 8 hours a day ;-)
	private TimeSpan _target = 8 * TimeSpan.HOUR;
    public TimeSpan target {
		get { return this._target; }
		set { this._target = value;}
	}
	

    


    public MainModel (File csv_directory) {
		set_column_types( new Type[]{ typeof(DateTime), typeof(string), typeof(bool)  } ) ;
		this.csv_directory = csv_directory;
	}

	public string print_iter(TreeIter myiter) {
		Value date = Value(typeof(DateTime));
		get_value(myiter, 0, out date);
		Value desc = Value(typeof(string));
		get_value(myiter, 1, out desc);
		Value pause = Value(typeof(bool));
		get_value(myiter, 2, out pause);
		return "%s\t%s\t%s".printf(((DateTime) date).format_iso8601(),
		      ((string) desc), ((bool) pause).to_string() );
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
		this.first_timestamp = new DateTime.local(now_tmp.get_year(), now_tmp.get_month(), now_tmp.get_day_of_month(),
		0, 0, 0);
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
		// add date
		csv_data = csv_data + _first_timestamp.format_iso8601() + "\n";
		// add target
		csv_data = csv_data + this.target.to_string() + "\n";
		// add transportation
		csv_data = csv_data + this.transportation + "\n";
		try {
			var file = this.csv_directory.get_child (filename);
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

	public void load_from_csv(string filename) {
		var file = this.csv_directory.get_child(filename);
			// delete if file already exists
			if (!file.query_exists ()) {
				return;
			}
			try {
				// Open file for reading and wrap returned FileInputStream into a
				// DataInputStream, so we can read line by line
				var dis = new DataInputStream (file.read ());
				string line;
				// Read lines until end of file (null) is reached
				while ((line = dis.read_line (null)) != null) {
					string[] items = line.split("\t");
					if (items.length == 3) {
					//stdout.printf ("%s\n", line);
					TreeIter iter;
					append(out iter);
					set(iter, 0, new DateTime.from_iso8601(items[0], null), 
							  1, items[1], 
							  2, bool.parse(items[2]) );
					}
					// TODO 
					var date_candidate = new DateTime.from_iso8601(items[0], null);
					if (date_candidate != null) {
						this.first_timestamp = date_candidate;
						continue;
					}
					var timespan = int64.parse(items[0]);
					if (timespan != 0) {
						this.target = timespan;
						continue;
					}
					this.transportation = items[0];
				}
			} catch (Error e) {
				error ("%s", e.message);
			}
		
	}

	// TODO Automatisch erkennen, ob wir von heute oder 
	// von der Vergangenheit sprechen...
	public void update_progress() {
		// How much time has passed since the last booking?
		// TODO Simplify
		TimeSpan sofarsogood = 0;
		TreeIter iter;
		DateTime last_booking = null;
		if (get_iter_first(out iter)) {
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

			while (iter_next(ref iter)) {
				DateTime next_date = getDate(iter);
				var pause = getPause(iter);
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
		var now = new DateTime.now();
		TimeSpan diff = 0;
		//print("%s\n", Utils.get_formatted_date(now));
		//print("%s\n", Utils.get_formatted_date(this.first_timestamp));
		//string bla  = "bla";
		
		if (Utils.get_formatted_date(now) == Utils.get_formatted_date(this.first_timestamp)
				&&  last_booking != null) {
			diff = now.difference(last_booking);
		}
		this.progress = diff + sofarsogood;
		this.remaining = target - progress;
		
	}
}