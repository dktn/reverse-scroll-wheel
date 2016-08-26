{CompositeDisposable} = require 'atom'
{TextEditor} = require 'atom'
{$} = require 'atom-space-pen-views'

module.exports =

  subscriptions: null
  active: false
  pluginName: 'Reverse Scroll Wheel'
  activateEntry: 'reverse-scroll-wheel.general.active'

  treeView: null

  config:
    general:
      title: 'General'
      type: 'object'
      properties:
        active:
          title: 'Activate'
          type: 'boolean'
          default: true

  activate: (state) ->
    @subscriptions = new CompositeDisposable

    @addToggle()
    @setActive (atom.config.get @activateEntry), false

    atom.config.onDidChange @activateEntry, () =>
      @setActive atom.config.get @activateEntry

    atom.packages.activatePackage('tree-view').then (treeViewPkg) =>
      @treeView = treeViewPkg.mainModule.createView()
      if @active
        @addReverseScrollWheelTreeView()

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->

  setActive: (active, notify = true) ->
    @active = active
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

  addToggle: ->
    @subscriptions.add atom.commands.add 'atom-workspace', 'reverse-scroll-wheel:toggle': =>
      @setActive(!@active)

  addReverseScrollWheelTreeView: ->
    @treeView.on 'mousewheel', (event) =>
      sensitivity = atom.config.get('editor.scrollSensitivity') / 100
      delta = event.originalEvent.wheelDeltaY * sensitivity
      if (delta != 0)
        @treeView.scrollTop(@treeView.scrollTop() + delta)
        event.preventDefault()
      false

  addReverseScrollWheel: ->
    if @treeView
      @addReverseScrollWheelTreeView()
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
    if @treeView
      @treeView.off 'mousewheel'
    editors = atom.workspace.getTextEditors()
    editors.forEach (editor) =>
      editorView = atom.views.getView(editor)
      $(editorView).off 'mousewheel'
