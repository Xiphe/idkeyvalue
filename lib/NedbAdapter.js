/* global module, require */

var ID_KEY = 'idkeyvalue_nedb_id';
var ANY = /.*/;

var helpers = require('./helpers');

function NedbAdapter(database, id) {
  this.database = database;
  this.id = id;
}

NedbAdapter.prototype._obj = function(key, value) {
  var obj = {};
  obj[key] = value;
  if (this.id) {
    obj[ID_KEY] = this.id;
  }

  return obj;
};

NedbAdapter.prototype.set = function(key, value, done) {
  var previous = this._obj(key, ANY);
  var update = this._obj(key, value);
  var options = { upsert: true };

  this.database.update(previous, update, options, function(err) {
    if (helpers.isFunction(done)) {
      done(err);
    }
  });
};

NedbAdapter.prototype.get = function(key, done) {
  var self = this;
  this.database.find(this._obj(key, ANY), function(err, docs) {
    if (err) {
      done(err);
    } else if (!docs.length || !docs[0][key]) {
      var msg = 'No entries of "' + key + '" found';
      if (self.id) {
        msg += ' for id "' + self.id + '"';
      }
      done(new Error(msg));
    } else {
      done(null, docs[0][key]);
    }
  });
};

NedbAdapter.prototype.remove = function(key, done) {
  this.database.remove(this._obj(key, ANY), function(err) {
    if (helpers.isFunction(done)) {
      done(err);
    }
  });
};

module.exports = NedbAdapter;
