
jQueryReady = ($) ->
  console.log 'jQuery Ready'
  $('.filldim').filldim()

yepnope
  both: [
    'http://code.jquery.com/jquery.min.js'
    'http://code.jquery.com/qunit/qunit-1.10.0.css'
    'http://code.jquery.com/qunit/qunit-1.10.0.js'
    '../css/jquery.filldim.css'
    '../js/jquery.filldim.js'
  ]

  complete: ->
    console.log 'jQuery loaded'
    jQuery(document).ready jQueryReady(jQuery)
