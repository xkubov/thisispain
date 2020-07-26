goog.provide 'wzk.ui.grid.CursorBasedPaginator'

goog.require 'goog.dom.classes'
goog.require 'goog.dom.forms'
goog.require 'goog.events.Event'
goog.require 'goog.functions'
goog.require 'goog.style'

goog.require 'wzk.array'
goog.require 'wzk.dom.dataset'
goog.require 'wzk.num'
goog.require 'wzk.ui.grid.CursorBasedPaginatorRenderer'
goog.require 'wzk.ui.grid.BasePaginator'


class wzk.ui.grid.CursorBasedPaginator extends wzk.ui.grid.BasePaginator

  ###*
    @param {Object} params
      renderer: {@link wzk.ui.grid.PaginatorRenderer}
      stateHolder: {wzk.ui.grid.StateHolder}
  ###
  constructor: (params) ->
    params.renderer ?= new wzk.ui.grid.CursorBasedPaginatorRenderer()
    super params

    @cursor = null
    @nextCursor = null

  ###*
    @param {Object} result
  ###
  init: (result) ->
    {@total, @count, @nextCursor} = result
    @nextCursor ?= null
    @count ?= @base

  ###*
    @return {boolean}
  ###
  isLast: ->
    @nextCursor is null

  ###*
    Re-renders a paginator according to a current page

    @param {Object} result
      total: {number}
      count: {number}
  ###
  refresh: (result) ->
    {@total, @count, @prevOffset, @nextOffset} = result
    if result.nextCursor
      @nextCursor = result.nextCursor
    else
      @nextCursor = null

    @renderer.clearPagingAndResult @
    @decorateInternal @getElement()
    @afterRendering()

    newClones = []
    for oldClone in @clones
      newClone = @clone()
      @dom.replaceNode newClone, oldClone
      newClones.push newClone
    @clones = newClones
    @show(true)

  ###*
    setter with callback that handles change
    @param {number} base
  ###
  setBase: (base) ->
    @base = base
    @cursor = null
    @nextCursor = null
    @dispatchChanged()

  ###*
    @protected
  ###
  hangPageListener: (paging) ->
    listener = goog.events.listen paging, goog.events.EventType.CLICK, (e) =>
      cursor = @renderer.getCursor e.target, @dom
      if cursor?
        @cursor = cursor
        @dispatchChanged()

    @listeners.push listener

  ###*
    @protected
  ###
  dispatchChanged: ->
    @cleanListeners()
    @dispatchEvent new goog.events.Event(wzk.ui.grid.BasePaginator.EventType.CHANGED, {base: @base, cursor: @cursor})

  ###*
    Reset paginator
    @param {wzk.resource.Query} query
  ###
  reset: (query) ->
    @cursor = null
    @nextCursor = null
    @buildQuery(query)

  ###*
    @param {wzk.resource.Query} query
  ###
  buildQuery: (query) ->
    query.base = @base
    query.cursor = @cursor

  ###*
    Clear data
    @return {boolean}
  ###
  clearData: ->
    @nextCursor is null

  ###*
    Reload data with delete element
    @return {boolean}
  ###
  reloadWithDelete: ->
    false

  ###*
    Clear data with sort
    @return {boolean}
  ###
  resetWithSort: ->
    true
