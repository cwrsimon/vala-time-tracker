using Gtk;

public class Utils {


	public static string get_formatted_timespan(TimeSpan remaining) {
		//print("%s\n", remaining.to_string());
		var remaining_hours = (remaining / TimeSpan.HOUR);
		var remaining_minutes = ((remaining - (TimeSpan.HOUR * remaining_hours)) / TimeSpan.MINUTE);
		var remaining_seconds = (remaining
		                         - (TimeSpan.HOUR * remaining_hours)
		                         - (TimeSpan.MINUTE * remaining_minutes)) / 1000 / 1000;

		return ("%02" + int64.FORMAT + ":%02" + int64.FORMAT + ":%02" + int64.FORMAT).
		       printf(remaining_hours, remaining_minutes, remaining_seconds);
	}

	public static string get_todays_date() {
		return new DateTime.now_local().format_iso8601().substring(0,10);
	}
	

}