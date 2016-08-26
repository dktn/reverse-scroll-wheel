{CompositeDisposable} = require 'atom'
{$} = require 'atom-space-pen-views'

module.exports =

  subscriptions: null
  active: false
  pluginName: 'Reverse Scroll Wheel'
  activateEntry: 'reverse-scroll-wheel.general.active'

  config:
    general:
      title: 'General'
      type: 'object'
      properties:
        active:
          title: 'Activate'
          type: 'boolean'
          default: true

  setActive: (active, notify = true) ->
    @active = active
    console.log "Activating ", @pluginName, " to ", @active
    atom.config.set @activateEntry, @active
    if active
      @addReverseScrollWheel()
      if notify
          atom.notifications.addInfo(@pluginName + ' activated')
    else
      @removeReverseScrollWheel()
      @subscriptions.dispose()
      @subscriptions = new CompositeDisposable
      @addToggle()
      if notify
          atom.notifications.addInfo(@pluginName + ' deactivated')

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @addToggle()

    atom.config.onDidChange @activateEntry, () =>
      @setActive atom.config.get @activateEntry

    @setActive (atom.config.get @activateEntry), false

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->

  addToggle: ->
    @subscriptions.add atom.commands.add 'atom-workspace', 'reverse-scroll-wheel:toggle': =>
      @setActive(!@active)

  addReverseScrollWheel: ->
    @subscriptions.add atom.workspace.observeTextEditors (editor) ->
      editorView = atom.views.getView(editor)
      $(editorView).on 'mousewheel', (event) ->
        sensitivity = atom.config.get('editor.scrollSensitivity') / 100
        delta = event.originalEvent.wheelDeltaY * sensitivity
        if (delta != 0)
          editorView.setScrollTop(editorView.getScrollTop() + delta)
          event.preventDefault()
        false

  removeReverseScrollWheel: ->
    editors = atom.workspace.getTextEditors()
    editors.forEach (editor) =>
      editorView = atom.views.getView(editor)
      $(editorView).off 'mousewheel'
