// Generated by CoffeeScript 1.6.1
(function() {
  var jQueryReady;

  jQueryReady = function($) {
    return console.log('jQuery Ready');
  };

  yepnope({
    both: ['http://code.jquery.com/jquery.min.js', 'http://code.jquery.com/qunit/qunit-1.10.0.css', 'http://code.jquery.com/qunit/qunit-1.10.0.js', '../css/jquery.filldim.css', '../js/jquery.filldim.js'],
    complete: function() {
      console.log('jQuery loaded');
      return jQuery(document).ready(jQueryReady(jQuery));
    }
  });

}).call(this);
