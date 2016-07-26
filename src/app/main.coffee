electron = require('electron')
app = electron.app
BrowserWindow = electron.BrowserWindow

mainWindow = null

createWindow = ->
    mainWindow = new BrowserWindow
        width: 800
        height: 600
        minWidth: 320
        minHeight: 320
        title: 'Ciph'

    mainWindow.loadURL "file://#{__dirname}/index.html"

    # mainWindow.webContents.openDevTools()

    mainWindow.on 'closed', -> mainWindow = null

app.on 'ready', createWindow

app.on 'window-all-closed', -> app.quit()

app.on 'activate', ->
    if mainWindow is null
        createWindow()
