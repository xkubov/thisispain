goog.provide 'wzk.ui.grid.BasePaginator'

goog.require 'goog.dom.classes'
goog.require 'goog.dom.forms'
goog.require 'goog.events.Event'
goog.require 'goog.functions'
goog.require 'goog.style'

goog.require 'wzk.array'
goog.require 'wzk.dom.dataset'
goog.require 'wzk.num'
goog.require 'wzk.ui.grid.BasePaginatorRenderer'


class wzk.ui.grid.BasePaginator extends wzk.ui.Component

  ###*
    @enum {string}
  ###
  @DATA:
    BASE: 'base'
    FORCE_DISPLAY: 'forceDisplay'

  ###*
    @enum {string}
  ###
  @EventType:
    CHANGED: 'changed'

  ###*
    @enum {string}
  ###
  @CLASSES:
    TOP: 'top'
    BOTTOM: 'bottom'

  ###*
    @type {number}
  ###
  @BASE = 10

  ###*
    @param {Object} params
      renderer: {@link wzk.ui.grid.PaginatorRenderer}
      stateHolder: {wzk.ui.grid.StateHolder}
  ###
  constructor: (params) ->
    super params
    {@stateHolder} = params
    @base = @stateHolder.getBase()
    @base = if @base >= 0 then @base else wzk.ui.grid.BasePaginator.BASE

    @clones = []
    @listeners = []
    @switcher = null
    @defBases = [10, 25, 50, 100, 500, 1000]
    @bases = @defBases
    @forceDisplay = false

  ###*
    @return {number}
  ###
  getBase: ->
    @base

  baseOrDefault: (value) =>
    wzk.array.filterFirst([@base, value], wzk.num.isPos, wzk.ui.grid.BasePaginator.BASE)

  ###*
    @param {Element} el
  ###
  loadData: (el) ->
    @base = wzk.dom.dataset.get(
      el, wzk.ui.grid.BasePaginator.DATA.BASE, goog.functions.compose(@baseOrDefault, wzk.num.parseDec))

  ###*
    @override
  ###
  canDecorate: (el) ->
    el? and goog.dom.classes.has el, wzk.ui.grid.BasePaginatorRenderer.CLASSES.PAGINATOR

  ###*
    @override
  ###
  afterRendering: ->
    @hangPageListener @renderer.getPagination(@)

  ###*
    @override
  ###
  decorateInternal: (el) ->
    @forceDisplay = wzk.dom.dataset.get(el, wzk.ui.grid.BasePaginator.DATA.FORCE_DISPLAY) is 'true'
    unless @bases
      switcherEl = el.querySelector '.' + wzk.ui.grid.BasePaginatorRenderer.CLASSES.BASE_SWITCHER
      @parseBases switcherEl

    @renderer.decorate @, el
    @setElementInternal el
    @showInternal(false)

  ###*
    @protected
  ###
  selectBase: ->
    @renderer.setSelectBase @base

  ###*
    @protected
    @param {Element} el
  ###
  parseBases: (el) ->
    if el? or @bases
      wzk.dom.dataset.get(el, 'bases', goog.json.parse, @defBases)

  ###*
    @return {Array.<number>}
  ###
  getBases: ->
    @bases

  ###*
    @protected
    @return {Element}
  ###
  clone: ->
    clone = @getElement().cloneNode(true)
    @hangPageListener(clone)
    goog.dom.classes.add(@getElement(), wzk.ui.grid.BasePaginator.CLASSES.TOP)
    goog.dom.classes.add(clone, wzk.ui.grid.BasePaginator.CLASSES.BOTTOM)
    goog.dom.classes.remove(clone, wzk.ui.grid.BasePaginator.CLASSES.TOP)
    @renderer.hangCustomerBaseInputListeners(@, clone)
    clone

  ###*
    @return {Element}
  ###
  createClone: ->
    return null unless @getElement()?
    clone = @clone()
    @clones.push clone
    clone

  cleanListeners: ->
    goog.events.unlistenByKey listener for listener in @listeners
    @listeners = []

  ###*
    @protected
    @return {boolean}
  ###
  canHide: ->
    @pageCount < 2 and not @forceDisplay

  ###*
    @param {boolean} visible
    @param {boolean=} force default is false
  ###
  show: (visible, force = false) ->
    if not force and @canHide()
      @showInternal(false)
    else
      @showInternal(visible)

  ###*
    @protected
    @param {boolean} visible
  ###
  showInternal: (visible) ->
    func = if visible then goog.dom.classes.remove else goog.dom.classes.add
    func(el, 'empty') for el in [@getElement()].concat(@clones)
