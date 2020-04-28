using Gdk;
using Gtk;

class DateCellRenderer : Gtk.CellRendererText {

	private DateTime _datetime;
	//private string _text;

	public DateTime datetime {
		get {return this._datetime;}
		set {
			this._datetime = value;
			this.text = value.format("%H:%M");
		}
	}

	//private Gtk.CellRendererText text_renderer;

	public DateCellRenderer() {
		GLib.Object ();
		//text_renderer = new Gtk.CellRendererText();

	}

//	public override void get_size (Gtk.Widget widget, Gdk.Rectangle? cell_area,
//	                               out int x_offset, out int y_offset,
//	                               out int width, out int height)
//	{
//x_offset = 0;
//y_offset = 0;
//width = 100;
//height = 50;
//Padding = 10;
//		@set("text", datetime.format("%H:%M"));
//		base.get_size(widget, cell_area, out x_offset, out y_offset, out width, out height);
//	}

	// render method
	/*
	   public override void render (Cairo.Context ctx, Gtk.Widget widget,
	                             Gdk.Rectangle background_area,
	                             Gdk.Rectangle cell_area,
	                             Gtk.CellRendererState flags)
	   {

	        text_renderer.@set("text", datetime.format("%H:%M"));
	        text_renderer.render(ctx, widget, background_area, cell_area, flags);

	   }
	 */


}