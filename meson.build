project('vala-time-tracker', ['vala', 'c'])
gtkdep = dependency('gtk+-3.0')
executable('vala-time-tracker', ['src/MainApp.vala', 
			'src/MainView.vala', 
			'src/MainModel.vala', 
			'src/DateCellRenderer.vala',
			 'src/Utils.vala'],
	dependencies : gtkdep, install: true, gui_app:true)

