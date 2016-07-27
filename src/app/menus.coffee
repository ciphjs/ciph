electron = require 'electron'
Menu     = electron.Menu
pack     = require electron.app.getAppPath() + '/package.json'
app      = electron.app
ipcMain  = electron.ipcMain
name     = app.getName()
appMenus = []
macos    = process.platform is 'darwin'

appMenu =
    label: name
    submenu: [
        label: 'About ' + name, role: 'about'
    ,
        type: 'separator'
    ,
        label: 'Preferences...'
        accelerator: 'Command+,'
        click: (item, focusedWin)->
            # ipcMain.emit 'click:preferences'
            focusedWin.send 'click:preferences'
    ,
        label: 'Services', role: 'services', submenu: []
    ,
        type: 'separator'
    ,
        label: 'Hide ', accelerator: 'Command+H', role: 'hide'
    ,
        label: 'Hide Others', accelerator: 'Command+Alt+H', role: 'hideothers'
    ,
        label: 'Show All', role: 'unhide'
    ,
        type: 'separator'
    ,
        label: 'Quit'
        accelerator: 'Command+Q'
        click: -> app.quit()
    ]

appMenus.push appMenu if macos


editMenu =
    label: 'Edit'
    submenu: [
        label: 'Undo', accelerator: 'CmdOrCtrl+Z', role: 'undo'
    ,
        label: 'Redo', accelerator: 'Shift+CmdOrCtrl+Z', role: 'redo'
    ,
        type: 'separator'
    ,
        label: 'Cut', accelerator: 'CmdOrCtrl+X', role: 'cut'
    ,
        label: 'Copy', accelerator: 'CmdOrCtrl+C', role: 'copy'
    ,
        label: 'Paste', accelerator: 'CmdOrCtrl+V', role: 'paste'
    ,
        label: 'Select All', accelerator: 'CmdOrCtrl+A', role: 'selectall'
    ]

appMenus.push editMenu


viewMenu =
    label: 'View'
    submenu: [
        label: 'Reload'
        accelerator: 'CmdOrCtrl+R'
        click: (item, focusedWin)-> focusedWin?.reload()
    ,
        label: 'Toggle Full Screen'
        accelerator: if macos then 'Ctrl+Command+F' else 'F11'
        click: (item, focusedWin)-> focusedWin?.setFullScreen not focusedWin.isFullScreen()
    ]

appMenus.push viewMenu


windowMenu =
    label: 'Window'
    role: 'window'
    submenu: [
        label: 'Minimize', accelerator: 'CmdOrCtrl+M', role: 'minimize'
    ,
        label: 'Close', accelerator: 'CmdOrCtrl+W', role: 'close'
    ]

if macos
    windowMenu.submenu.push type: 'separator'
    windowMenu.submenu.push label: 'Bring All to Front', role: 'front'

appMenus.push windowMenu


helpMenu =
    label: 'Help'
    role: 'help'
    submenu: [
        label: 'Website'
        click: (item)-> electron.shell.openExternal(pack.homepage)
    ,
        label: 'GitHub'
        click: (item)-> electron.shell.openExternal(pack.repository.url)
    ]

appMenus.push helpMenu

module.exports =
    appMenus: appMenus
    # contextEditable: Menu.buildFromTemplate copyMenu
