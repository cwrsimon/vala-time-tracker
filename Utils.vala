using Gtk;

public class Utils {


	public static string get_formatted_timespan(TimeSpan remaining) {
		//print("%s\n", remaining.to_string());
		var remaining_hours = (remaining / TimeSpan.HOUR);
		var remaining_minutes = ((remaining - (TimeSpan.HOUR * remaining_hours)) / TimeSpan.MINUTE);
		var remaining_seconds = (remaining
		                         - (TimeSpan.HOUR * remaining_hours)
		                         - (TimeSpan.MINUTE * remaining_minutes)) / 1000 / 1000;

		return "%s' %s'' %s".
		       printf(remaining_hours.to_string(), remaining_minutes.to_string(), remaining_seconds.to_string());
	}

	

}