

    fail = -> throw new simplegeneric.NoSuchMethod()

    simplegeneric = (key, argn=0, default_method=fail) ->
        if typeof argn is "function"
            default_method = argn
            argn = 0
        fn = -> default_method()
        fn.key = key
        fn.argn = argn
        fn.default_method = default_method
        fn

    class simplegeneric.NoSuchMethod extends Error
        constructor: -> Error.apply(this, arguments)

    module.exports = simplegeneric
