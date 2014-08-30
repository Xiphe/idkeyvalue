/* global module, require */

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

ObjectAdapter.prototype.get = function(key, silent, done) {
  var value, error;

  if (helpers.isFunction(silent)) {
    done = silent;
    silent = false;
  }

  if (!helpers.isUndefined(this.store[key])) {
    value = this.store[key];
  } else if (!silent) {
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

module.exports = ObjectAdapter;
