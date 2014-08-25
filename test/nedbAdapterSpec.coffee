NedbAdapter = require '../lib/NedbAdapter'
specHelper = require './specHelper'
Datastore = require 'nedb'
fs = require 'fs'

testDriver =
  fakeGetError: (instance) ->
    myError = new Error 'something went wrong!'
    sinon.stub(instance.database, 'find').callsArgWithAsync 1, myError
    return myError
  fakeSetError: (instance) ->
    myError = new Error 'something else went wrong!'
    sinon.stub(instance.database, 'update').callsArgWithAsync 3, myError
    return myError
  fakeRemoveError: (instance) ->
    myError = new Error 'something went completely wrong!'
    sinon.stub(instance.database, 'remove').callsArgWithAsync 1, myError
    return myError


inMemoryDb = new Datastore
specConfig =
  name: 'NedbAdapter in memory'
  getInstance: (id) ->
    new NedbAdapter inMemoryDb, id
  getDecoupledInstance: (id) ->
    anotherDb = new Datastore
    new NedbAdapter anotherDb, id
  testDriver: testDriver

specHelper specConfig


fileDb = new Datastore filename: './test.nedb', autoload: true
specConfig =
  name: 'NedbAdapter in memory'
  getInstance: (id) ->
    new NedbAdapter fileDb, id
  getDecoupledInstance: (id) ->
    anotherDb = new Datastore filename: './test2.nedb', autoload: true
    new NedbAdapter anotherDb, id
  testDriver: testDriver
  cleanup: ->
  	fs.unlink './test.nedb', ->
  	fs.unlink './test2.nedb', ->

specHelper specConfig
