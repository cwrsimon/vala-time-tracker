using Gtk;

public class MainView : Window {

    private Gtk.ListStore listmodel;

    public MainView () {
        this.title = "TreeView Sample";
        set_default_size (250, 100);
        var view = new TreeView ();
        setup_treeview (view);
        
        var mainLayout = new Box(Gtk.Orientation.VERTICAL, 6);
        add (mainLayout);

        mainLayout.pack_start(view);


        //this.destroy.connect (hide_on_delete );
        this.delete_event.connect (hide_on_delete );

        var add_button = new Button();
        add_button.set_label("Add entry");
        mainLayout.pack_start(add_button);

        add_button.clicked.connect( () => {

            print("Hello World!");
            TreeIter iter;
            this.listmodel.append (out iter);
            var now = new DateTime.now_local ();
            this.listmodel.set_value (iter, 4, now.to_string());
    
        });
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

        this.listmodel = new Gtk.ListStore (5, typeof (string), typeof (string),
                                          typeof (string), typeof (string), typeof (string) );
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
        view.insert_column_with_attributes (-1, "Date", new CellRendererText (), "text", 4);

        TreeIter iter;
        listmodel.append (out iter);
        listmodel.set (iter, 0, "My Visacard", 1, "card", 2, "102,10", 3, "red");

        listmodel.append (out iter);
        listmodel.set (iter, 0, "My Mastercard", 1, "card", 2, "10,20", 3, "red");
    }

    
}