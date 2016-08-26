{CompositeDisposable} = require 'atom'
{$} = require 'atom-space-pen-views'

module.exports =

  subscriptions: null
  active: false
  pluginName: 'Reverse Scroll Wheel'

  packageName: 'reverse-scroll-wheel'
  activateEntry: @packageName + '.general.active'

  config:
    general:
      title: 'General'
      type: 'object'
      properties:
        active:
          title: 'Activate'
          type: 'boolean'
          default: true

  setActive: (active) =>
    @active = active
    console.log "Activating ", @pluginName, " to ", @active
    if active
      @addReverseScrollWheel()
      atom.notifications.addInfo(@pluginName + ' activated')
    else
      @removeReverseScrollWheel()
      @subscriptions.dispose()
      @subscriptions = new CompositeDisposable
      @addToggle()
      atom.notifications.addInfo(@pluginName + ' deactivated')

  activate: (state) ->

    console.log "start ", @pluginName
    @subscriptions = new CompositeDisposable
    @addToggle()

    atom.config.onDidChange @activateEntry, () =>
        @setActive atom.config.get @activateEntry

    @setActive true

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->

  toggle: ->
    # @active = !@active
    @setActive(!@active)
    # if @active
    #     @addReverseScrollWheel()
    #     atom.notifications.addInfo(@pluginName + ' activated')
    # else
    #     @removeReverseScrollWheel()
    #     @subscriptions.dispose()
    #     @subscriptions = new CompositeDisposable
    #     @addToggle()
    #     atom.notifications.addInfo(@pluginName + ' deactivated')

  addToggle: ->
    @subscriptions.add atom.commands.add 'atom-workspace', 'reverse-scroll-wheel:toggle': => @toggle()

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
