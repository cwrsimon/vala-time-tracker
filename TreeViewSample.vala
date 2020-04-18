using Gtk;

public class TreeViewSample : Window {

    public TreeViewSample () {
        this.title = "TreeView Sample";
        set_default_size (250, 100);
        var view = new TreeView ();
        setup_treeview (view);
        add (view);
        //this.destroy.connect (hide_on_delete );
        this.delete_event.connect (hide_on_delete );
    }

    private void destroy_me() {
        this.hide();
    }

    private void setup_treeview (TreeView view) {

        /*
         * Use ListStore to hold accountname, accounttype, balance and
         * color attribute. For more info on how TreeView works take a
         * look at the GTK+ API.
         */

        var listmodel = new Gtk.ListStore (4, typeof (string), typeof (string),
                                          typeof (string), typeof (string));
        view.set_model (listmodel);

        view.insert_column_with_attributes (-1, "Account Name", new CellRendererText (), "text", 0);
        view.insert_column_with_attributes (-1, "Type", new CellRendererText (), "text", 1);

        var cell = new CellRendererText ();
        cell.set ("foreground_set", true);
        cell.editable = true;
        cell.edited.connect ((path, new_text) => {
                stdout.printf (path + "\n");
                stdout.printf (new_text + "\n");
                stdout.flush ();
                Gtk.TreePath tPath = new Gtk.TreePath.from_string(path);
  var model = view.get_model();
  TreeIter myiter;

  var res = model.get_iter(out myiter, tPath);
  if (res == true) {
  // listmodel.set(myiter, 0, new_text);
  listmodel.set_value(myiter, 2, new_text);
  }
            });
        view.insert_column_with_attributes (-1, "Balance", cell, "text", 2, "foreground", 3);

        TreeIter iter;
        listmodel.append (out iter);
        listmodel.set (iter, 0, "My Visacard", 1, "card", 2, "102,10", 3, "red");

        listmodel.append (out iter);
        listmodel.set (iter, 0, "My Mastercard", 1, "card", 2, "10,20", 3, "red");
    }

    
}