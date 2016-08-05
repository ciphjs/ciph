electron = require('electron')
menus    = require('./menus')
{BrowserWindow, app, ipcMain, Menu} = electron

macos = process.platform is 'darwin'
mainWindow = null
onQuit = false

createWindow = ->
    mainWindow = new BrowserWindow
        width: 800
        height: 600
        minWidth: 320
        minHeight: 320
        autoHideMenuBar: true
        title: 'Ciph'

    mainWindow.loadURL "file://#{__dirname}/index.html"
    Menu.setApplicationMenu Menu.buildFromTemplate menus.appMenus

    # mainWindow.webContents.openDevTools()
    mainWindow.on 'close', (e)->
        unless onQuit
            e.preventDefault()
            mainWindow.hide()

    mainWindow.on 'closed', (e)-> mainWindow = null

    ipcMain.on 'messageCount', (e, count)->
        app.setBadgeCount count if typeof count is 'number'

    ipcMain.on 'clientChange', ->
        if mainWindow and not mainWindow.isFocused() and macos
            bID = app.dock.bounce 'informational'

            mainWindow.removeAllListeners 'focus' # NOTE: bad solution
            mainWindow.once 'focus', ->
                app.dock.cancelBounce bID


app.on 'ready', createWindow
app.on 'before-quit', -> onQuit = true
app.on 'window-all-closed', -> app.quit() unless macos

app.on 'activate', ->
    if mainWindow is null
        createWindow()

    else
        mainWindow.show()
