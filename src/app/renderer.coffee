$ = require('jquery')
Controller = require('./controller')
{ipcRenderer, remote} = require('electron')
{Menu, MenuItem} = remote

$ ->
    window.app = new Controller()

    app.on 'unreadMessages', (count)->
        ipcRenderer.send 'messageCount', count

    app.on 'newClients', ->
        ipcRenderer.send 'clientChange'

    menu = new Menu()
    menu.append new MenuItem label: 'Cut', accelerator: 'CmdOrCtrl+X', role: 'cut'
    menu.append new MenuItem label: 'Copy', accelerator: 'CmdOrCtrl+C', role: 'copy'
    menu.append new MenuItem label: 'Paste', accelerator: 'CmdOrCtrl+V', role: 'paste'

    window.addEventListener 'contextmenu', (e)->
        e.preventDefault()
        menu.popup remote.getCurrentWindow()
    , false
