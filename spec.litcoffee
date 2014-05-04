    simplegeneric = require 'simplegeneric'

    describe "The simplegeneric() API", ->

        it "is a function", ->
            simplegeneric.should.be.a('function')

        it "provides a NoSuchMethod error", ->
            simplegeneric.should.have.property('NoSuchMethod')
            .and.have.property('prototype').and.be.instanceOf(Error)

        it "accepts a unique ID for its key, returning a function", ->
            for key in ["some.unique.id", "another.key"]
                simplegeneric(key).should.be.a('function')
                .and.have.property('key').and.equal(key)

        it "accepts an argument position (default of 0)", ->
            for argn in [null, 0, 1, 2, 3]
                simplegeneric("my.unique.id", argn).should.be.a('function')
                .and.have.property('argn').and.equal(argn ? 0)

        it "accepts a default implementation (defaulting argn to 0)", ->
            for fn in [(->42), (->77)]
                gf = simplegeneric("some.id", fn)
                gf.should.be.a('function')
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
            it "requires a non-negative, numeric argument position"
            it "only accepts an optional number and optional function"


    describe "A generic function", ->

        KEY = "simplegeneric.spec.example"
        example = simplegeneric(KEY, default_method = -> no)
        base_method = -> "base"
        stringy_method = -> true
        ob1_method = -> "ob1"
        ob1 = {}
        ob2 = {}
        class Base then ;
        class Subclass extends Base then ;

        checkByBase = (fn, match=(f)->f()) ->
            for tgt in [new Base, new Subclass]
                should.equal fn(tgt), match base_method
            for tgt in [String, RegExp]
                should.equal fn(tgt), match default_method
            for tgt in ["x", /x/]
                should.equal fn(tgt), match stringy_method

        checkByType = (fn, match=(f)->f()) ->
            for tgt in [Base, Subclass]
                should.equal fn(tgt), match base_method
            for tgt in [String, RegExp]
                should.equal fn(tgt), match stringy_method
            for tgt in ["x", /x/, new Base, new Subclass, ob1, ob2]
                should.equal fn(tgt), match default_method

        checkByObject = (fn, match=(f)->f()) ->
            fn(ob1).should.equal match ob1_method
            for tgt in [ob2, 42]
                should.equal fn(tgt), match default_method
            for tgt in [String::, RegExp::]
                should.equal fn(tgt), match stringy_method







        it "calls its default method by default", ->
            for fn in [spy.named("42", ->42), spy.named("77", ->77)]
                simplegeneric("some.id", fn)()
                fn.should.be.calledOnce

        it "throws NoSuchMethod without a default method", ->
            simplegeneric("no.such").should.throw simplegeneric.NoSuchMethod


































        describe "accepts type registrations via .when_type()", ->

            it "has a .when_type() method", ->
                example.should.have.property('when_type').and.be.a('function')

            it "requires at least two arguments", ->
                for args in [ [], [Number] ]
                    (-> example.when_type.apply(example, args))
                        .should.throw TypeError, /two arguments/

                (-> example.when_type(String, RegExp, stringy_method))
                    .should.not.throw()
                (-> example.when_type(Base, base_method))
                    .should.not.throw()

            it "requires a function as the last argument", ->
                for args in [ [ob1, ob2], [String, Number, ob2] ]
                    (-> example.when_type.apply(example, args))
                        .should.throw TypeError,
                            /last argument must be function/i


        describe "accepts object registrations via .when_object()", ->

            it "has a .when_object() method", ->
                example.should.have.property('when_object').and.be.a('function')

            it "requires at least two arguments", ->
                for args in [ [], [Number::] ]
                    (-> example.when_object.apply(example, args))
                        .should.throw TypeError, /two arguments/
                (-> example.when_object(ob1, ob1_method))
                    .should.not.throw()

            it "requires a function as the last argument", ->
                for args in [ [ob1, ob2], [String::, Number::, ob2] ]
                    (-> example.when_object.apply(example, args))
                        .should.throw TypeError,
                            /last argument must be function/i


        describe "can tell you whether registrations exist", ->

            it "via .method_for(ob, exact=no)", ->
                example.should.have.property('method_for').and.be.a('function')
                for check in [checkByBase, checkByObject]
                    check(
                        (ob) -> example.method_for(ob) ? default_method
                        (f)  -> f
                    )
                for ob in [String::, RegExp::, Base::, Subclass::, ob1, "str"]
                    should.exist example.method_for(ob)
                for ob in [String, RegExp, Base, ob2, 42]
                    should.not.exist example.method_for(ob)

            it "via .method_for_type(ob, exact=no)", ->
                example.should.have.property('method_for_type').and.be.a('function')
                checkByBase(
                    (ob) -> example.method_for_type(ob.constructor) ? default_method
                    (f)  -> f
                )
                checkByType(
                    (ob) -> example.method_for_type(ob) ? default_method
                    (f)  -> f
                )

            it "via .method_for(ob, exact=yes)", ->
                for ob in [String::, RegExp::, Base::, ob1]
                    should.exist example.method_for(ob, yes)
                for ob in [String, RegExp, Base, Subclass::, ob2, 42, "str"]
                    should.not.exist example.method_for(ob, yes)

            it "via .method_for_type(ob, exact=yes)", ->
                for ob in [String, RegExp, Base]
                    should.exist example.method_for_type(ob, yes)
                for ob in [Subclass, String::, RegExp::, Base::, ob1, "str"]
                    should.not.exist example.method_for_type(ob, yes)





        describe "invokes methods appropriately", ->

            it "dispatches correctly by type", ->
                checkByBase example

            it "dispatches correctly by object", ->
                checkByObject example

            it "passes through its arguments and context", ->
                thing = gf: simplegeneric "context.check", dm = spy.named "dm"
                thing.gf.when_object thing, om = spy.named "om"
                thing.gf(1, 2, 3)
                thing.gf(thing, 4, 5)

                dm.should.be.calledOnce
                dm.should.be.calledOn(thing).calledWithExactly(1,2,3)
                dm.should.be.calledBefore(om)
                om.should.be.calledOnce
                om.should.be.calledAfter(dm)
                om.should.be.calledOn(thing).calledWithExactly(thing, 4, 5)
                
            it "shares methods from gfs with the same key", ->
                checkByBase fn = simplegeneric(KEY, example.default_method)
                checkByObject fn

            it "doesn't share mathods from gfs with different keys"

            it "dispatches based on its argument position", ->
                for argn in [0..9]
                    gf = simplegeneric(KEY, argn, example.default_method)
                    checkByBase fn = (arg) ->
                        args = []
                        args[argn] = arg
                        gf(args...)
                    checkByObject fn






        describe "manages properties sensibly", ->

            it "doesn't expose its private properties", ->
                ob1.should.be.empty
                ob1.should.not.include.keys(KEY)
    
            it "doesn't allow changing its informational properties", ->
                example.argn = 9
                example.argn.should.equal(0)
                example.key = "what"
                example.key.should.equal(KEY)
                old = example.default_method
                example.default_method = /99/
                example.default_method.should.equal(old)


    chai = require 'chai'
    chai.use require 'sinon-chai'
    should = chai.should()

    {spy} = sinon = require 'sinon'

    spy.named = (name, args...) ->
        s = if this is spy then spy(args...) else this
        s.displayName = name
        s















