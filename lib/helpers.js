/* global module */
(function() {
  'use strict';

  module.exports = {
    isFunction: function(thing) {
      return (thing instanceof Function);
    },
    isUndefined: function(thing) {
      return (typeof thing === 'undefined');
    }
  };
})();
