$ = require('jquery')
Controller = require('./controller')
{ipcRenderer, remote, shell} = require('electron')
{Menu, MenuItem} = remote

$ ->
    window.app = new Controller()

    app.on 'ready', ->
        ipcRenderer.send 'startMessenger'

    app.on 'unreadMessages', (count)->
        ipcRenderer.send 'messageCount', count

    app.on 'newClients', ->
        ipcRenderer.send 'clientChange'

    ipcRenderer.on 'click:preferences', ->
        app.openPreferences()

    menu = new Menu()
    menu.append new MenuItem label: 'Cut', accelerator: 'CmdOrCtrl+X', role: 'cut'
    menu.append new MenuItem label: 'Copy', accelerator: 'CmdOrCtrl+C', role: 'copy'
    menu.append new MenuItem label: 'Paste', accelerator: 'CmdOrCtrl+V', role: 'paste'

    $(window).bind 'contextmenu', (e)->
        if $(e.target).closest('input, textarea, .jsText, [contenteditable]').length > 0
            e.preventDefault()
            menu.popup remote.getCurrentWindow()

    $('body').on 'click', 'a[href]', (e)->
        e.preventDefault()
        shell.openExternal this.href
