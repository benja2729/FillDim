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

  $.filldim =
    justify: 'none'

  $.fn.filldim = (options, trigger) ->
    defaults = $.extend {}, $.filldim,
      target: @selector

    @each (index) =>
      el = @eq index
      data = el.data 'FillDim'
      if $.isEmptyObject data
        opts = $.extend {}, defaults,
          dims: el.data 'dims'
          target: el.data 'target'
          width: el.data 'width'
        , options

        justify = el.prop('class').match /\w+(?=-justify)/
        if justify isnt null then opts.justify = justify[0]

        el.data 'FillDim', (new FillDim el, opts)
      else if typeof options is 'string' then data[options](trigger)
      else null

  class FillDim

    # ------------------------- #
    # Static Members
    # ------------------------- #

    @wrapperClass: 'filldim-wrapper'
    @targetClass: 'filldim-target'
    @getWrapper: (selector = FillDim.wrapperClass) -> $('<div>').addClass selector


    # ------------------------- #
    # Prototype Members
    # ------------------------- #

    constructor: (element, opts) ->
      @opts = opts
      console.log @opts

      # State variable to tell if object has initialized
      @initialized = false

      # State variable to tell if object loaded with wrapper
      @native = false

      @element = element
      @setDims()
      @setTarget()
      @setWrapper()

      @initialized = true

    render: ->
      @setTarget()
      @setWrapper()

    # ------------------------- #
    # Wrapper Functions
    # ------------------------- #

    hasWrapper: ->
      if @wrapper isnt undefined then return @wrapper
      for selector in [".#{FillDim.wrapperClass}", '.filldim-widescreen', '.filldim-standard']
        if @element.parent(selector).length > 0 then return selector
      false

    setWrapper: (selector = FillDim.wrapperClass) ->
      wrapper = @hasWrapper()

      if not wrapper
        target = (if @hasTarget() then @getTarget() else @element)
        target.wrap FillDim.getWrapper(selector)
        @wrapper = ".#{selector}"

      else
        if not @initialized then @native = true
        @wrapper = wrapper

    # @justify()

    getWrapper: -> @element.parent @wrapper


    # ------------------------- #
    # Target Functions
    # ------------------------- #

    hasTarget: ->
      if @target isnt undefined then return true
      @getTarget().length > 0

    setTarget: (target = @opts.target) ->
      obj = @element.closest target

      if obj.length is 0
        obj = @element
        target = @opts.target

      if @hasTarget() then @getTarget().removeClass FillDim.targetClass

      obj.addClass FillDim.targetClass
      @target = target

    getTarget: -> @element.closest ".#{FillDim.targetClass}"


    # ------------------------- #
    # Dimension Functions
    # ------------------------- #
 
    calcDims: ->
      target = (if @hasTarget() then @getTarget() else @element)
      cols = target.attr 'width'
      rows = target.attr 'height'

      if cols is undefined or rows is undefined
        cols = target.width()
        rows = target.height()
      else
        cols = parseFloat cols, 10
        rows = parseFloat rows, 10

      rows / cols

    setDims: (dims = @opts.dims) ->
      console.log "setDims: #{dims}"
      if not @initialized and @native then return null
      dims ?= @dims or @calcDims()
      @dims = @parseDimString(dims)
      if @hasWrapper() then @getWrapper().css 'padding-top', @getDims()
      @dims

    getDims: -> "#{@dims * 100}%"

    parseDimString: (str) ->
      str = str.toString(10)
      if /:/.test(str)
        [cols, rows] = str.split ':'
        rows / cols
      else
        num = parseFloat str, 10
        if /%/.test(str) then num /= 100
        num
