class DateCellRenderer : Gtk.CellRenderer {

    public DateTime datetime { get; set; }

    private Gtk.CellRendererText text_renderer;

    public DateCellRenderer() {
        GLib.Object ();
        text_renderer = new Gtk.CellRendererText();
    }

    public override void get_size (Gtk.Widget widget, Gdk.Rectangle? cell_area,
    out int x_offset, out int y_offset,
    out int width, out int height)
{
//x_offset = 0;
//y_offset = 0;
//width = 100;
//height = 50;
//Padding = 10;
text_renderer.@set("text", datetime.format("%x %H:%M"));
text_renderer.get_size(widget, cell_area, out x_offset, out y_offset, out width, out height);
}

    // render method
	public override void render (Cairo.Context ctx, Gtk.Widget widget,
    Gdk.Rectangle background_area,
    Gdk.Rectangle cell_area,
    Gtk.CellRendererState flags)
    {

        text_renderer.@set("text", datetime.format("%x %H:%M"));
        text_renderer.render(ctx, widget, background_area, cell_area, flags);

    }

}