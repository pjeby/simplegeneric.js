    fail = -> throw new simplegeneric.NoSuchMethod()

    defProp = (ob, key, value, opts) ->
        if Object.defineProperty?
            opts ?= Object.create(null)
            opts.value = value
            Object.defineProperty ob, key, opts
        else
            ob[key] = value

    defProps = (ob, props, opts={}) ->
        for own key, value of props
            defProp ob, key, value, opts
        return ob

    simplegeneric = (key, argn=0, default_method=fail) ->
        if typeof argn is "function"
            default_method = argn
            argn = 0
        fn = -> (arguments[argn]?[key] ? default_method).apply(this, arguments)
        return defProps fn, {
            argn, key, default_method,
            when_object: (targets..., method) ->
                if arguments.length<2
                    throw new TypeError "At least two arguments required"
                if typeof method isnt "function"
                    throw new TypeError "Last argument must be function"         
                for t in targets
                    defProp t, key, method, {configurable:yes}
                return   
            when_type: (targets..., method) ->
                for t,p in [].slice.call(arguments, 0, arguments.length-1)
                    arguments[p] = t::
                fn.when_object(arguments...)
            has_object: (o) -> o[key]?
            has_exact: (o) -> Object.hasOwnProperty.call(o,key)
            has_type: (o) -> o?.prototype?[key]?
        }
        return fn


    class simplegeneric.NoSuchMethod extends Error
        constructor: -> Error.apply(this, arguments)

    module.exports = simplegeneric
    




































