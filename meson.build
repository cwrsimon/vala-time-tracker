project('playground', ['vala', 'c'])
gtkdep = dependency('gtk+-3.0')
appindicator = dependency('appindicator3-0.1')
executable('TimeTracker', ['MainApp.vala', 'MainView.vala', 'DateCellRenderer.vala'],
 dependencies : gtkdep, install: true)
executable('dummy', ['indicator-example.vala'],
 dependencies : [gtkdep, appindicator], install: true)

