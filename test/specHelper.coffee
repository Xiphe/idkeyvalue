module.exports = (config) ->
  someId = 7
  anotherId = 14

  if config.cleanup
    after config.cleanup

  describe config.name, ->
    adapter = null

    describe 'interface', ->
      beforeEach ->
        adapter = config.getInstance()

      it 'should provide a set method', ->
        adapter.set.should.be.instanceof Function

      it 'should provide a get method', ->
        adapter.get.should.be.instanceof Function

      it 'should provide a remove method', ->
        adapter.remove.should.be.instanceof Function

    [false, true].forEach (hasId) ->
      describe (if hasId then ' with id' else ' without id'), ->
        beforeEach ->
          adapter = config.getInstance(if hasId then someId)

        it 'should set, get and remove values', (done) ->
          myValue = 'someValue'
          myKey = 'someKey'

          adapter.set myKey, myValue, ->
            adapter.get myKey, (err, value) ->
              value.should.equal myValue
              adapter.remove myKey, ->
                adapter.get myKey, (err, value) ->
                  myValue.should.not.equal value
                  done()

        it 'should share data between instances', (done) ->
          myValue = 'someValue'
          myKey = 'someKey'

          anotherAdapter = config.getInstance(if hasId then someId)

          adapter.set myKey, myValue, ->
            anotherAdapter.get myKey, (err, value) ->
              value.should.equal myValue
              adapter.remove myKey, ->
                anotherAdapter.get myKey, (err, value) ->
                  myValue.should.not.equal value
                  done()

        it 'should return an error when trying to get an undefined key', (done) ->
          adapter.get 'someKey', (err) ->
            err.should.be.instanceof Error
            err.message.should.match /someKey/
            done()

        if hasId
          it 'should not get values from another id', (done) ->
            sharedKey = 'someKey'
            idAValue = 'someValue'
            anotherAdapter = config.getInstance anotherId
            adapter.set sharedKey, idAValue, ->
              anotherAdapter.get sharedKey, (err, value) ->
                idAValue.should.not.equal value
                adapter.remove sharedKey, done

          it 'should not remove values from another id', (done) ->
            sharedKey = 'someKey'
            idAValue = 'someValue'
            anotherAdapter = config.getInstance anotherId
            adapter.set sharedKey, idAValue, ->
              anotherAdapter.remove sharedKey, ->
                adapter.get sharedKey, (err, value) ->
                  idAValue.should.equal value
                  adapter.remove sharedKey, done

    describe 'decoupled instance', ->
      decoupledAdapter = null

      beforeEach ->
        decoupledAdapter = config.getDecoupledInstance()

      it 'should not get values from a decoupled instance', (done) ->
        sharedKey = 'someKey'
        idAValue = 'someValue'
        adapter.set sharedKey, idAValue, ->
          decoupledAdapter.get sharedKey, (err, value) ->
            idAValue.should.not.equal value
            adapter.remove sharedKey, done

      it 'should not delete values from a decoupled instance', (done) ->
        sharedKey = 'someKey'
        idAValue = 'someValue'
        adapter.set sharedKey, idAValue, ->
          decoupledAdapter.remove sharedKey, ->
            adapter.get sharedKey, (err, value) ->
              idAValue.should.equal value
              adapter.remove sharedKey, done

    describe 'fire and forget', ->
      beforeEach ->
        adapter = config.getInstance()

      it 'should not throw when setting values without done callback', (done) ->
        myValue = 'someValue'
        myKey = 'someKey'

        set = ->
          adapter.set myKey, myValue

        set.should.not.throw Error

        setTimeout ->
          adapter.get myKey, (err, value) ->
            myValue.should.equal value
            adapter.remove myKey, done
        , 5

      it 'should not throw when removing values without done callback', (done) ->
        myValue = 'someValue'
        myKey = 'someKey'

        adapter.set myKey, myValue, ->
          remove = ->
            adapter.remove myKey, myValue

          remove.should.not.throw Error

          setTimeout ->
            adapter.get myKey, (err, value) ->
              myValue.should.not.equal value
              done()
          , 5

    if config.testDriver
      describe 'errors', ->
        beforeEach ->
          adapter = config.getInstance()

        if config.testDriver.fakeGetError
          it 'should pass database errors (get)', (done) ->
            error = config.testDriver.fakeGetError(adapter)
            adapter.get 'myKey', (err) ->
              err.should.equal error
              done()

        if config.testDriver.fakeSetError
          it 'should pass database errors (set)', (done) ->
            error = config.testDriver.fakeSetError(adapter)
            adapter.set 'myKey', 'myValue', (err) ->
              err.should.equal error
              done()

        if config.testDriver.fakeRemoveError
          it 'should pass database errors (remove)', (done) ->
            error = config.testDriver.fakeRemoveError(adapter)
            adapter.remove 'myValue', (err) ->
              err.should.equal error
              done()



