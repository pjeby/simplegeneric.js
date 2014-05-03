
    describe "The simplegeneric() API", ->

        simplegeneric = null
        
        it "is importable", ->
            simplegeneric = require 'simplegeneric'

        it "is a function", ->
            simplegeneric.should.be.instanceOf(Function)
