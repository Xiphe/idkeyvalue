/* global module, require */
(function() {
  'use strict';

  var helpers = require('./helpers');

  module.exports = function(key, defaultValue, updater, done) {
    var self = this;
    var hasDefault = true;
    var getArgs = [key];

    if (!helpers.isFunction(done) && helpers.isFunction(defaultValue)) {
      done = updater;
      updater = defaultValue;
      hasDefault = false;
    } else {
      getArgs.push(defaultValue);
    }

    getArgs.push(function applyUpdate(err, value) {
      if (err) { return done(err); }

      updater(value, function(err, value) {
        if (err) { return done(err); }

        self.set(key, value, function(err) {
          if (err) { return done(err); }

          done(null, value);
        });
      });
    });

    self.get.apply(self, getArgs);
  };
})();
