###
  TODO: data-width and .filldim.justifyright or .filldim.justifyleft
        De-couple setting configurations and rendering
        Add event hooks
        Add compiled JS to bootstrap-all.js in vubstrap
        Import LESS files into bootstrap
        Commit everything to GitHub
  Filldim jQuery plugin
  @element.data('dims')
  @element.data('target')  = element around which to wrap
###

do ($ = jQuery) ->

  # ------------------------- #
  # ------------------------- #

  defaults =
    dims: 1
    width: 1
    float: 'none'

  wrapper = $('<div>').addClass('filldim-wrapper').css 'position': 'relative'

  targetCSS =
    'width': '100%'
    'height': '100%'
    'position': 'absolute'
    'top': 0
    'left': 0
    'float': 'none'

  events = ['propertyWillChange', 'propertyDidChange', 'filldimWillDestroy', 'filldimDidDestroy']

  propertyObservers =
    dims: ->
      dims = @get 'dims'
      width = @get 'width'

      # Since padding percentages are calculated based on
      # the parent div's width, the 'height' of the dimension
      # needs to be in reference with the width, so we multiply
      # the percent width of the wrapper by the relative
      # dimensions the element should have
      paddingTop = (width * parseDims(dims) * 100) + '%'
      @get('wrapper').css {paddingTop}

    width: ->
      width = (@get('width') * 100) + '%'
      @get('wrapper').css {width}

      # Change the element's dimensions if not queued to change already
      # to make sure the dimensions are proportional to the width 
      if @_queue.indexOf('dims') < 0 then propertyObservers.dims.call this

    float: -> @get('wrapper').css 'float', @get('float')

  parseDims = (dims) -> switch $.type dims
    when 'number' then dims
    when 'string'
      if /:/.test dims
        d = dims.split ':'
        parseFloat(d[1], 10) / parseFloat(d[0], 10)
      else parseFloat(dims, 10) / 100
    else 1


  # ------------------------- #
  # ------------------------- #
  
  class FillDim

    # ------------------------- #
    # Prototype Members
    # ------------------------- #

    constructor: (element, opts) ->
      @element = element
      @wrapper()
      @element.css targetCSS

      @set opts

    _propertyCache: {}
    _queue: []

    propertiesWillChange: (props) ->
      @_queue = [null]
      @set prop, value for own prop, value of props
      @propertiesDidChange()

    propertiesDidChange: ->
      @_queue.shift()
      @propertyDidChange prop for prop in @_queue
      @_queue = []

    propertyWillChange: (prop) ->
      @element.trigger 'propertyWillChange', [prop, this]

      if @_queue[0] is null then @_queue.push prop
      else @propertyDidChange prop

    propertyDidChange: (prop) ->
      propertyObservers[prop].call this
      @element.trigger 'propertyDidChange', [prop, this]

    set: (key, value) ->
      if $.type(key) is 'object'
        @propertiesWillChange key
      else

        prop = this[key]
        if $.isFunction prop
          @_propertyCache[key] = prop.call this, key, value
        else this[key] = value

        if propertyObservers[key] then @propertyWillChange key

    get: (key) ->
      p = @_propertyCache
      if p[key] then return p[key]

      prop = this[key]
      if $.isFunction prop then prop.call(this) else prop

    wrapper: ->
      element = @get 'element'
      parent = element.parent '[class*="filldim-"]'
      if parent.length is 0
        parent = wrapper.clone()
        element.wrap parent
      parent

    destroy: ->
      el = @element
      el.trigger 'filldimWillDestroy'

      el.off(events.slice 0, events.length-1)
      el.css @get('initCSS')
      el.unwrap()
      el.removeData 'filldim'

      el.trigger 'filldimDidDestroy'
      el.off events.slice(events.length-1)


  # -------------------------------------- #
  # Attach FillDim functionality
  # to the jQuery chainable helper
  # -------------------------------------- #

  getAttrOpts = (element) ->
    width = element.attr 'width'
    dims = element.data 'dims'
    ret = {}

    if width
      w = parseFloat(width, 10)
      height = element.attr 'height'
      regex = /px/

      if height and regex.test(height) and regex.test(width)
        ret.dims = parseFloat(height, 10) / w

      else if /%/.test width
        ret.width = w / 100

    if not $.isEmptyObject dims then ret.dims = dims

    ret

  getCssOpts = (element, hash) ->
    width = element.width()
    height = element.height()
    console.log element.parent().width(), width

    dims = height / width
    width /= element.parent().width()
    float = hash.float
    {dims, width, float}

  getInitCSS = (element) ->
    ret = {}
    for own key of targetCSS
      ret[key] = element.css key
    ret

  init = (options) ->
    attrOpts = getAttrOpts this
    initCSS = getInitCSS this
    cssOpts = getCssOpts this, initCSS
    # defaults, initCSSopts, attrOpts, options, {initCSS}
    opts = $.extend {}, defaults, cssOpts, attrOpts, options, {initCSS}

    console.log '-------------------'
    console.log {defaults, cssOpts, attrOpts, options}
    console.log opts
    console.log '-------------------'

    @data 'filldim', new FillDim(this, opts)
  
  $.fn.filldim = (options, trigger) ->
    @each (index) =>
      el = @eq index
      data = el.data 'filldim'

      if $.isEmptyObject data then init.call el, options 
      else if $.type options is 'string' and trigger
        data.set options, trigger
      else if options is 'destroy' then data.destroy()

  $(document).ready -> $('.filldim').filldim()
