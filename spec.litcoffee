    simplegeneric = require 'simplegeneric'

    describe "The simplegeneric() API", ->

        it "is a function", ->
            simplegeneric.should.be.Function

        it "provides a NoSuchMethod error", ->
            simplegeneric.should.have.property('NoSuchMethod')
            .and.have.property('prototype').and.be.Error

        it "accepts a unique ID for its key, returning a function", ->
            for key in ["some.unique.id", "another.key"]
                simplegeneric(key).should.be.Function
                .and.have.property('key').and.equal(key)

        it "accepts an argument position (default of 0)", ->
            for argn in [null, 0, 1, 2, 3]
                simplegeneric("my.unique.id", argn).should.be.Function
                .and.have.property('argn').and.equal(argn ? 0)
            
        it "accepts a default implementation (defaulting argn to 0)", ->
            for fn in [(->42), (->77)]
                gf = simplegeneric("some.id", fn)
                gf.should.be.Function
                .and.have.property('default_method').and.equal(fn)
                gf.should.have.property('argn').and.equal(0)

        it "accepts both a position and a default implementation", ->
            for argn in [0..3]
                for fn in [(->), (->)]
                    gf = simplegeneric("some.id", argn, fn)
                    gf.should.have.property('default_method').and.equal(fn)
                    gf.should.have.property('argn').and.equal(argn)

        describe "does argument validation", ->
            it "requires a string first"
            it "only accepts an optional number and optional function"



    describe "A generic function", ->

        KEY = "simplegeneric.spec.example"
        example = simplegeneric(KEY, -> no)
        ob1 = {}
        ob2 = {}
        class Base then ;
        class Subclass extends Base then ;

        it "calls its default method by default", ->
            for fn in [(->42), (->77)]
                gf = simplegeneric("some.id", fn)
                gf().should.equal fn()

        it "throws NoSuchMethod without a default method", ->
            simplegeneric("no.such").should.throw simplegeneric.NoSuchMethod

        describe "accepts type registrations via .when_type()", ->

            it "has a .when_type() method", ->
                example.should.have.property('when_type').and.be.Function

            it "requires at least two arguments", ->
                for args in [ [], [Number] ]
                    (-> example.when_type.apply(example, args))
                        .should.throw(TypeError).and.throw /two arguments/

                (-> example.when_type(String, RegExp, -> true))
                    .should.not.throw()
                (-> example.when_type(Base, -> "base"))
                    .should.not.throw()

            it "requires a function as the last argument", ->
                for args in [ [ob1, ob2], [String, Number, ob2] ]
                    (-> example.when_type.apply(example, args))
                        .should.throw(TypeError)
                        .and.throw /last argument must be function/i




        describe "accepts object registrations via .when_object()", ->

            it "has a .when_object() method", ->
                example.should.have.property('when_object').and.be.Function

            it "requires at least two arguments", ->
                for args in [ [], [Number::] ]
                    (-> example.when_object.apply(example, args))
                        .should.throw(TypeError).and.throw /two arguments/
                (-> example.when_object(ob1, -> "ob1"))
                    .should.not.throw()

            it "requires a function as the last argument", ->
                for args in [ [ob1, ob2], [String::, Number::, ob2] ]
                    (-> example.when_object.apply(example, args))
                        .should.throw(TypeError)
                        .and.throw /last argument must be function/i

        describe "can tell you whether registrations exist", ->

            it "via .has_type()", ->
                example.should.have.property('has_type').and.be.Function
                for ob in [String, RegExp, Base]
                    example.has_type(ob).should.be.true
                for ob in [String::, RegExp::, Base::, ob1, "a string"]
                    example.has_type(ob).should.be.false

            it "via .has_object()", ->
                example.should.have.property('has_object').and.be.Function
                for ob in [String::, RegExp::, Base::, Subclass::, ob1, "a string"]
                    example.has_object(ob).should.be.true
                for ob in [String, RegExp, Base, ob2, 42]
                    example.has_object(ob).should.be.false

            it "via .has_exact()", ->
                example.should.have.property('has_exact').and.be.Function
                for ob in [String::, RegExp::, Base::, ob1]
                    example.has_exact(ob).should.be.true
                for ob in [String, RegExp, Base, Subclass::, ob2, 42, "a string"]
                    example.has_exact(ob).should.be.false

        describe "invokes methods appropriately", ->

            it "passes through its arguments"
        
            it "dispatches based on its argument position"

            it "shares methods from gfs with the same key"

            it "doesn't share mathods from gfs with different keys"

            it "dispatches correctly by type", ->
                example(new Base).should.equal "base"
                example(new Subclass).should.equal "base"
                example(String).should.be.false
                example(RegExp).should.be.false
                example("x").should.be.true
                example(/x/).should.be.true

            it "dispatches correctly by object", ->
                example(ob1).should.equal "ob1"
                example(ob2).should.be.false
                example(42).should.be.false

        it "doesn't expose its private properties"

















