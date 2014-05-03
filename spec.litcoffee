
    simplegeneric = require 'simplegeneric'

    describe "The simplegeneric() API", ->

        it "is a function", ->
            simplegeneric.should.be.Function

        it "provides a NoSuchMethod error", ->
            simplegeneric.should.ownProperty('NoSuchMethod')
            .and.ownProperty('prototype').and.be.Error

        it "accepts a unique ID for its key, returning a function", ->
            for key in ["some.unique.id", "another.key"]
                simplegeneric(key).should.be.Function
                .and.ownProperty('key').and.equal(key)

        it "accepts an argument position (default of 0)", ->
            for argn in [null, 0, 1, 2, 3]
                simplegeneric("my.unique.id", argn).should.be.Function
                .and.ownProperty('argn').and.equal(argn ? 0)
            
        it "accepts a default implementation (defaulting argn to 0)", ->
            for fn in [(->42), (->77)]
                gf = simplegeneric("some.id", fn)
                gf.should.be.Function
                .and.ownProperty('default_method').and.equal(fn)
                gf.should.ownProperty('argn').and.equal(0)

        it "accepts both a position and a default implementation", ->
            for argn in [0..3]
                for fn in [(->), (->)]
                    gf = simplegeneric("some.id", argn, fn)
                    gf.should.ownProperty('default_method').and.equal(fn)
                    gf.should.ownProperty('argn').and.equal(argn)

        describe "does argument validation", ->
            it "requires a string first"
            it "only accepts an optional number and optional function"



    describe "A generic function", ->

        it "calls its default implementation by default", ->
            for fn in [(->42), (->77)]
                gf = simplegeneric("some.id", fn)
                gf().should.equal fn()

        it "throws NoSuchMethod without a default implementation", ->
            simplegeneric("no.such").should.throw simplegeneric.NoSuchMethod

        it "accepts type registrations via .when_type()"
        it "accepts object registrations via .when_object()"

        it "can be queried for an implementation with .has_type()"
        it "can be queried for an implementation with .has_object()"
        
        it "dispatches based on its argument position"

        it "shares methods from gfs with the same key"

        it "doesn't share mathods from gfs with different keys"


























