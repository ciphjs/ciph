electron = require('electron')
app = electron.app
ipc = electron.ipcMain
BrowserWindow = electron.BrowserWindow
macos = process.platform is 'darwin'

mainWindow = null

createWindow = ->
    mainWindow = new BrowserWindow
        width: 800
        height: 600
        minWidth: 320
        minHeight: 320
        autoHideMenuBar: true
        title: 'Ciph'

    mainWindow.loadURL "file://#{__dirname}/index.html"

    # mainWindow.webContents.openDevTools()

    ipc.on 'messageCount', (e, count)->
        console.log 'mmmmmm', arguments
        if typeof count is 'number'
            app.setBadgeCount count

    if macos
        ipc.on 'clientChange', ->
            mainWindow.removeAllListeners 'focus' # NOTE: bad solution

            if mainWindow and not mainWindow.isFocused()
                bID = app.dock.bounce 'informational'
                mainWindow.once 'focus', ->
                    app.dock.cancelBounce bID

    mainWindow.on 'closed', -> mainWindow = null

app.on 'ready', createWindow
app.on 'ready', -> require('./menus')

app.on 'window-all-closed', -> app.quit()

app.on 'activate', ->
    if mainWindow is null
        createWindow()
