using Gtk;

public class MainView : Window {

    private Gtk.ListStore listmodel;

    public MainView () {
        this.title = "TreeView Sample";
        set_default_size (1000, 400);
        var view = new TreeView ();
        setup_treeview (view);
        
        var mainLayout = new Box(Gtk.Orientation.VERTICAL, 6);
        add (mainLayout);

        mainLayout.pack_start(view);

        this.delete_event.connect (hide_on_delete );

        var add_button = new Button();
        add_button.set_label("Add entry");
        mainLayout.pack_start(add_button);

        add_button.clicked.connect( () => {

        add_entry(); 
        });
    }

    public void add_entry() {
        TreeIter iter;
        this.listmodel.append (out iter);
        var now = new DateTime.now_local();
        this.listmodel.set_value (iter, 0, now);
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

        this.listmodel = new Gtk.ListStore (3, typeof (DateTime), typeof (string),
                                          typeof (bool));
        view.set_model (listmodel);

        var date_cell = new DateCellRenderer ();
        //date_cell.editable = true;
        /* 
        date_cell.edited.connect ( (path, new_text) => {
            print(path); print("\n");
            print(new_text); print("\n");

            print("======");
        });
        */
        var col1_idx = view.insert_column_with_attributes (-1, "Timestamp", date_cell, "datetime", 0);
        var col1 = view.get_column(0);
        col1.resizable = true;
        col1.set_min_width(300);

        var cell = new CellRendererText ();
        cell.set ("foreground_set", true);
        cell.editable = true;
        cell.edited.connect ((path, new_text) => {
                
                Gtk.TreePath tPath = new Gtk.TreePath.from_string(path);
                var model = view.get_model();
                TreeIter myiter;

                 var res = model.get_iter(out myiter, tPath);
                if (res == true) {
                 listmodel.set_value(myiter, 1, new_text);
                }
        });
        view.insert_column_with_attributes (-1, "Projekt", cell, "text", 1);

        var col2 = view.get_column(1);
        col2.set_resizable(true);
        col2.set_expand(true);
        //col2.set_min_width(500);


        var toggle = new CellRendererToggle ();
        toggle.toggled.connect ((toggle, path) => {
            var tree_path = new TreePath.from_string (path);
            var model = view.get_model();

            TreeIter iter;
            model.get_iter (out iter, tree_path);
            listmodel.set_value (iter, 2, !toggle.active);
        });
        var col3_idx = view.insert_column_with_attributes (-1, "Pause", toggle, "active", 2);
        var col3 = view.get_column(2);
        col3.set_resizable(true);
        col3.set_min_width(100);


    }

    
}