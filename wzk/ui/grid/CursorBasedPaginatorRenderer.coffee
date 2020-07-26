goog.require 'goog.array'
goog.require 'goog.dom.classes'
goog.require 'goog.dom.forms'
goog.require 'goog.functions'
goog.require 'goog.string'
goog.require 'goog.style'

goog.require 'wzk.dom.dataset'
goog.require 'wzk.json'
goog.require 'wzk.num'
goog.require 'wzk.ui.menu.Menu'
goog.require 'wzk.ui.menu.MenuItemRenderer'
goog.require 'wzk.ui.menu.MenuRenderer'
goog.require 'wzk.ui.grid.BasePaginatorRenderer'


class wzk.ui.grid.CursorBasedPaginatorRenderer extends wzk.ui.grid.BasePaginatorRenderer

  ###*
    @override
  ###
  createDom: (paginator) ->
    el = super paginator
    dom = paginator.getDomHelper()
    @attachSwitcher paginator, el, dom
    el

  ###*
    @param {wzk.ui.Component} paginator
    @param {Element} el
  ###
  decorate: (paginator, el) ->
    dom = (`/** @type {wzk.dom.Dom} */`) paginator.getDomHelper()
    C = wzk.ui.grid.BasePaginatorRenderer.CLASSES

    D = wzk.ui.grid.BasePaginatorRenderer.DATA

    pagination = dom.cls(C.PAGINATION, el) ? el

    @decoratePagination(paginator, pagination, dom)

    @customBaseLabel = wzk.dom.dataset.get(
      el, D.CUSTOM_BASE_LABEL, String, wzk.ui.grid.BasePaginatorRenderer.CUSTOM_BASE_LABEL)
    @customBaseErrorMessage = wzk.dom.dataset.get(
      el, D.CUSTOM_BASE_ERROR_MESSAGE, String, wzk.ui.grid.BasePaginatorRenderer.CUSTOM_BASE_ERROR_MESSAGE)

    @baseRange = wzk.dom.dataset.get(el, D.BASE_RANGE, goog.functions.compose(@baseRangeOrDefault, wzk.json.parse))
    if wzk.dom.dataset.get(el, D.BASE_TYPE) is wzk.ui.grid.BasePaginatorRenderer.BASE_TYPES.CUSTOM
      @deleteCustomerBaseElementIfExists(paginator, el)
      @createCustomBaseEl(paginator, el)

    paging = dom.cls(C.PAGING, el) ? el
    if @switcher
      dom.insertChildAt paging, @switcher, 0
    else
      switcher = dom.cls C.BASE_SWITCHER, el
      @decorateSwitcher paginator, switcher, dom

    goog.style.setStyle(el, 'visibility', 'inherit')

  ###*
    @protected
    @param {wzk.ui.Component} paginator
    @param {Element} el
    @param {goog.dom.DomHelper} dom
  ###
  decoratePagination: (paginator, el, dom) ->
    C = wzk.ui.grid.BasePaginatorRenderer.CLASSES

    next = dom.cls C.NEXT, el
    if paginator.isLast()
      @inactivateEl next
    else
      @setCursor next, paginator.nextCursor

  ###*
    @protected
    @param {Element} el
    @param {number} page
  ###
  setCursor: (el, nextCursor) ->
    goog.dom.classes.remove(el, wzk.ui.grid.BasePaginatorRenderer.CLASSES.INACTIVE)
    wzk.dom.dataset.set(el, wzk.ui.grid.BasePaginatorRenderer.DATA.CURSOR, nextCursor)

  ###*
    @protected
    @param {Element} el
    @param {string} add
    @param {string} remove
  ###
  switchClass: (el, add, remove) ->
    goog.dom.classes.add el, add
    goog.dom.classes.remove el, remove
    wzk.dom.dataset.remove el, wzk.ui.grid.BasePaginatorRenderer.DATA.CURSOR

  ###*
    @param {Element} el
    @param {wzk.dom.Dom} dom
  ###
  getCursor: (el, dom) ->
    CURSOR = wzk.ui.grid.BasePaginatorRenderer.DATA.CURSOR
    PAGINATION = wzk.ui.grid.BasePaginatorRenderer.CLASSES.PAGINATION
    while true
      if not el or goog.dom.classes.has(el, PAGINATION)
        return null
      if el.tagName is @itemTag and wzk.dom.dataset.has(el, CURSOR)
        return wzk.dom.dataset.get(el, CURSOR)
      el =  dom.getParentElement el
