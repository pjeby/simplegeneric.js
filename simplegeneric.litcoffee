    fail = -> throw new simplegeneric.NoSuchMethod()

    simplegeneric = (key, argn=0, default_method=fail) ->
        if typeof argn is "function"
            default_method = argn
            argn = 0
        fn = -> (arguments[0]?[key] ? default_method)()
        fn.key = key
        fn.argn = argn
        fn.default_method = default_method

        fn.when_object = (targets..., method) ->
            if arguments.length<2
                throw new TypeError "At least two arguments required"
            if typeof method isnt "function"
                throw new TypeError "Last argument must be function"               
            for t in targets
                t[key] = method

        fn.when_type = (targets..., method) ->
            for t,p in [].slice.call(arguments, 0, arguments.length-1)
                arguments[p] = t::
            fn.when_object(arguments...)

        fn.has_object = (o) -> o[key]?
        fn.has_exact = (o) -> Object.hasOwnProperty.call(o,key)
        fn.has_type = (o) -> o?.prototype?[key]?
        return fn

    class simplegeneric.NoSuchMethod extends Error
        constructor: -> Error.apply(this, arguments)

    module.exports = simplegeneric
