ObjectAdapter = require '../lib/ObjectAdapter'

store = {}

specConfig =
  name: 'ObjectAdapter'
  getInstance: (id) ->
    new ObjectAdapter store, id
  getDecoupledInstance: (id) ->
    new ObjectAdapter {}, id

require('./specHelper')(specConfig)
