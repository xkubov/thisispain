goog.provide 'wzk.ui.TagContainer'
goog.provide 'wzk.ui.TagContainer.EventType'

goog.require 'goog.ui.Control'
goog.require 'wzk.ui.TagContainerRenderer'
goog.require 'goog.object'
goog.require 'goog.events.Event'

class wzk.ui.TagContainer extends goog.ui.Control

  ###*
    A container for @link{wzk.ui.Tag} that fires these events:
      - ADD: when a tag is added, fires this in an event as a target
      - ADD_TAG: when a tag is added, fires the tag in an event as a target
      - REMOVE: when a tag is removed, fires this in an event as a target
      - REMOVE_TAG: when a tag is removed, fires the tag in an event as a target

    @constructor
    @extends {goog.ui.Control}
    @param {goog.ui.ControlContent=} content Text caption or DOM structure
    @param {goog.ui.ControlRenderer=} renderer
    @param {goog.dom.DomHelper=} dom
  ###
  constructor: (content = null, renderer = wzk.ui.TagContainerRenderer.getInstance(), dom = null) ->
    super(content, renderer, dom)
    @tags = {}

  ###*
    @public
    @param {string} name
    @param {*} model
    @param {wzk.ui.TagRenderer=} renderer
  ###
  addTag: (name, model, renderer) ->
    t = new wzk.ui.Tag(name, renderer)
    t.setModel(model)
    @add(t)

  ###*
    @param {wzk.ui.Tag} tag
  ###
  add: (tag) ->
    if @tags[@getKey(tag.getModel())]?
      # tag is already present, do not add it
      return

    @hangListener(tag)
    @addChild tag, true
    @tags[@getKey(tag.getModel())] = tag
    @dispatchEvent(wzk.ui.TagContainer.EventType.ADD)
    @dispatchEvent(@buildEvent(wzk.ui.TagContainer.EventType.ADD_TAG, tag))

  ###*
    @return {Object.<string, wzk.ui.Tag>}
  ###
  getTags: ->
    @tags

  ###*
    @return {boolean}
  ###
  isEmpty: ->
    goog.object.getCount(@tags) is 0

  ###*
    @protected
    @return {string}
  ###
  getKey: (model) ->
    model.toString()

  ###*
    @protected
    @param {wzk.ui.Tag} tag
  ###
  hangListener: (tag) ->
    goog.events.listenOnce tag, wzk.ui.Tag.EventType.REMOVE, (e) =>
      e.stopPropagation()
      goog.object.remove(@tags, @getKey(e.target.getModel()))
      @removeChild e.target, true
      @dispatchEvent(wzk.ui.TagContainer.EventType.REMOVE)
      @dispatchEvent(@buildEvent(wzk.ui.TagContainer.EventType.REMOVE_TAG, tag))

  ###*
    @protected
    @param {string} type
    @param {wzk.ui.Tag} tag
    @return {goog.events.Event}
  ###
  buildEvent: (type, tag) ->
    new goog.events.Event(type, tag)

  ###*
    @override
  ###
  setEnabled: (enabled) ->
    super enabled
    for k, v of @tags
      v.setEnabled enabled
    undefined

###*
  @enum {string}
###
wzk.ui.TagContainer.EventType =
  ADD: 'add'
  REMOVE: 'remove'
  ADD_TAG: 'add-tag'
  REMOVE_TAG: 'remove-tag'