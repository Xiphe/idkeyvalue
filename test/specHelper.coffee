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

        it 'should not get other values', (done) ->
          valueA = 'a'
          valueB = 'b'
          keyA = 'someKeyA'
          keyB = 'someKeyB'
          adapter.set keyA, valueA, ->
            adapter.set keyB, valueB, ->
              adapter.get keyB, (err, value) ->
                value.should.equal valueB
                adapter.get keyA, (err, value) ->
                  value.should.equal valueA

                  adapter.remove keyA, ->
                    adapter.remove keyB, done

        it 'should store objects', (done) ->
          myNestedObject =
            string: 'foo',
            number: 7
            float: 7.1
            boolean: false
            array: ['a', 'b']
            hash: lorem: 'ipsum'

          myKey = 'someKey'

          adapter.set myKey, myNestedObject, ->
            adapter.get myKey, (err, value) ->
              value.should.be.an 'object'
              value.string.should.be.a 'string'
              value.number.should.be.a 'number'
              value.float.should.be.a 'number'
              value.boolean.should.be.a 'boolean'
              value.array.should.be.an 'array'
              value.hash.should.be.an 'object'
              value.hash.lorem.should.be.a 'string'

              adapter.remove myKey, done

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

        it 'should not return an error when get is called with a default value', (done) ->
          adapter.get 'someKey', true, (err, value) ->
            err.should.equal null if err
            done err

        it 'should return default values when no entry is found', (done) ->
          myDefault = 'a'
          adapter.get 'someKey', myDefault, (err, value) ->
            value.should.equal myDefault
            done err

        it 'should not return default values when entry is found', (done) ->
          myKey = 'someKey'
          myValue = 'a'
          myDefault = 'b'
          adapter.set myKey, myValue, ->
            adapter.get myKey, myDefault, (err, value) ->
              value.should.not.equal myDefault
              value.should.equal myValue
              adapter.remove myKey, done

        if hasId
          it 'should not get values from another id', (done) ->
            sharedKey = 'someKey'
            idAValue = 'someValue'
            anotherAdapter = config.getInstance anotherId
            adapter.set sharedKey, idAValue, ->
              anotherAdapter.get sharedKey, (err, value) ->
                idAValue.should.not.equal value
                adapter.remove sharedKey, done

          it 'should not overwrite values with another id', (done) ->
            sharedKey = 'someKey'
            idAValue = 'someValue'
            idBValue = 'someOtherValue'
            anotherAdapter = config.getInstance anotherId
            adapter.set sharedKey, idAValue, ->
              anotherAdapter.set sharedKey, idBValue, ->
                adapter.get sharedKey, (err, value) ->
                  idAValue.should.equal value
                  anotherAdapter.remove sharedKey, ->
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

        else
          it 'should not get values with id', (done) ->
            sharedKey = 'someKey'
            myValue = 'someValue'
            idAdapter = config.getInstance someId
            idAdapter.set sharedKey, myValue, ->
              adapter.get sharedKey, (err, value) ->
                myValue.should.not.equal value
                idAdapter.remove sharedKey, done

          it 'should not overwrite values with id', (done) ->
            sharedKey = 'someKey'
            myValue = 'someValue'
            myOtherValue = 'someOtherValue'
            idAdapter = config.getInstance someId
            idAdapter.set sharedKey, myValue, ->
              adapter.set sharedKey, myOtherValue, ->
                idAdapter.get sharedKey, (err, value) ->
                  err.should.equal null if err
                  myValue.should.equal value
                  idAdapter.remove sharedKey, ->
                    adapter.remove sharedKey, done

          it 'should not delete values with id', (done) ->
            sharedKey = 'someKey'
            myValue = 'someValue'

            idAdapter = config.getInstance someId
            idAdapter.set sharedKey, myValue, ->
              adapter.remove sharedKey, ->
                idAdapter.get sharedKey, (err, value) ->
                  err.should.equal null if err
                  myValue.should.equal value
                  idAdapter.remove sharedKey, done

        describe 'update helper', ->
          it 'should update values', (done) ->
            myValue = 'someValue'
            myUpdateValue = 'anotherValue'
            myKey = 'someKey'

            updater = (value, done) ->
              value.should.equal myValue
              done null, myUpdateValue

            adapter.set myKey, myValue, ->
              adapter.update myKey, updater, (err, value) ->
                value.should.equal myUpdateValue

                adapter.get myKey, (err, value) ->
                  value.should.equal myUpdateValue

                  adapter.remove myKey, done

          it 'should update default values', (done) ->
            myDefaultValue = 'someDefaultValue'
            myKey = 'someKey'

            updater = (value, done) ->
              value.should.equal myDefaultValue
              done null, value

            adapter.get myKey, (err, value) ->
              err.should.be.an.instanceof Error

              adapter.update myKey, myDefaultValue, updater, (err, value) ->
                value.should.equal myDefaultValue

                adapter.get myKey, (err, value) ->
                  value.should.equal myDefaultValue

                  adapter.remove myKey, done

          describe 'errors', ->
            it 'should break on get error', (done) ->
              myKey = 'someKey'
              myError = new Error 'Test';
              sinon.stub(adapter, 'get').callsArgWithAsync 1, myError
              updater = sinon.spy()

              adapter.update myKey, updater, (err, value) ->
                err.should.equal myError
                updater.should.not.have.been.called
                done()

            it 'should break on update error', (done) ->
              myKey = 'someKey'
              myError = new Error 'Test';
              updater = (value, done) ->
                done myError

              sinon.spy adapter, 'set'

              adapter.update myKey, 'asd', updater, (err, value) ->
                err.should.equal myError
                adapter.set.should.not.have.been.called
                done()

            it 'should break on set errors', (done) ->
              myKey = 'someKey'
              myValue = 'lorem'
              myError = new Error 'Test';
              sinon.stub(adapter, 'set').callsArgWithAsync 2, myError
              updater = (value, done) ->
                done null, value

              adapter.update myKey, myValue, updater, (err, value) ->
                adapter.set.should.have.been.calledWith myKey, myValue
                err.should.equal myError
                done()

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
