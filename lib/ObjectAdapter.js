/* global module, require */
(function() {
  'use strict';

  var ID_PREFIX = 'id.';
  var GLOBAL_KEY = 'global';

  var helpers = require('./helpers');

  function ObjectAdapter(store, id) {
    var key = GLOBAL_KEY;

    this.id = id;

    if (id) {
      key = ID_PREFIX + id;
    }

    if (!store[key]) {
      store[key] = {};
    }

    this.store = store[key];
  }

  ObjectAdapter.prototype.set = function(key, value, done) {
    this.store[key] = value;
    if (helpers.isFunction(done)) {
      done();
    }
  };

  ObjectAdapter.prototype.get = function(key, defaultValue, done) {
    var value, error, hasDefault = true;

    if (!helpers.isFunction(done) && helpers.isFunction(defaultValue)) {
      done = defaultValue;
      hasDefault = false;
    }

    if (!helpers.isUndefined(this.store[key])) {
      value = this.store[key];
    } else if (hasDefault) {
      value = defaultValue;
    } else {
      error = new Error('Not found: ' + key);
    }

    done(error, value);
  };

  ObjectAdapter.prototype.remove = function(key, done) {
    if (typeof this.store[key] !== 'undefined') {
      delete this.store[key];
    }

    if (helpers.isFunction(done)) {
      done();
    }
  };

  ObjectAdapter.prototype.update = require('./update');

  module.exports = ObjectAdapter;
})();
