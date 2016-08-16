{CompositeDisposable} = require 'atom'
{$} = require 'atom-space-pen-views'

module.exports = ReverseScrollWheel =
  subscriptions: null
  active: true

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @addReverseScrollWheel()
    @addToggle()

  addToggle: ->
    console.log 'ReverseScrollWheel addToggle'
    @subscriptions.add atom.commands.add 'atom-workspace', 'reverse-scroll-wheel:toggle': => @toggle()

  addReverseScrollWheel: ->
    console.log 'ReverseScrollWheel addReverseScrollWheel'
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
    console.log 'ReverseScrollWheel removeReverseScrollWheel'
    editors = atom.workspace.getTextEditors()
    editors.forEach (editor) =>
      editorView = atom.views.getView(editor)
      $(editorView).off 'mousewheel'

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->

  toggle: ->
    @active = !@active
    if @active
        console.log 'ReverseScrollWheel activated'
        @addReverseScrollWheel()
    else
        console.log 'ReverseScrollWheel deactivated'
        @removeReverseScrollWheel()
        @subscriptions.dispose()
        @addToggle()
