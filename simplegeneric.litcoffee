# Single-Dispatch Generic Functions

The ``simplegeneric()`` function creates an extensible or "generic" function,
that can have different behavior for different kinds of objects, and can have
new behavior added by callers, not just the function's original author.

The returned function will choose its behavior by "dispatching" on one of its
arguments, selecting a behavior ("method") based on that argument's type.  If
a specific method isn't found, it uses a "default method" as a fallback.  Each
generic function also has a unique name (or "key"), that will be used to
look up methods.

By default, the dispatch argument is argument 0 - the first argument.  And the
default "default method" is to throw a ``simplegeneric.NoSuchMethod`` error.
But the key has no default, because every generic function needs a universally
unique identifier, such such as a URL, email address, RFC-compliant UUID, etc.

    module.exports = simplegeneric = (key, argn=0, default_method=fail) ->
        unless typeof key is "string"
            throw new TypeError "unique key string required"

        if typeof argn is "function" and arguments.length<3
            default_method = argn
            argn = 0

        unless typeof argn is "number" and argn>=0
            throw new TypeError "argument number must be >=0"

        unless typeof default_method is "function"
            throw new TypeError "default method must be function"

        unless arguments.length<= 3
            throw new TypeError "excess arguments"








## Dispatching

The function returned by ``simplegeneric`` is quite simple: it looks up a
method on the dispatch argument, using the unique key.  If not found, the
default method is called instead.  That's the whole thing in a nutshell.

        fn = -> (arguments[argn]?[key] ? default_method).apply(this, arguments)

## Registering Methods

For ease of use, however, a number of additional properties and methods are
added to the function before it's returned.  In particular, the ``when_object()``
and ``when_type()`` methods are added, so that you can easily register methods
for the function to use with specific objects, prototypes, or constructors,
without needing to know the function's key or duplicate it throughout your
code, while keeping the registered method invisble to normal iteration.

``when_object()`` takes one or more objects, and a method to register, and
then adds the method to those objects directly, as a read-only, non-enumerable
(hidden from iteration) property.  ``when_type()`` works similarly, except that
you pass it class constructors (i.e. functions), and it registers methods with
their prototypes instead.

        return defProps fn, {

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


## Introspection

In addition to the registration methods, there are matching introspection
methods that you can use to look up what methods have been registered, if any.
``method_for()`` tells you if a method is available on an object, while
``method_for_type()`` does the same for a class constructor.  Both methods
accept an optional second argument: an "exact" flag that means, "only return
a method if one was explicitly defined for this *exact* object or constructor,
rather than on one of its parent prototypes".

In other words, without the exact flag, these methods tell you what method
*would be called* if you invoked the generic function on that object or an
instance of that class.  But with the exact flag, they tell you what method
*was registered* on that specific object or class prototype.

(In either case, the returned value is undefined if no method applied.)

            method_for: (o, exact=no) ->
                if not exact or o? and Object.hasOwnProperty.call(o,key)
                    return o?[key]
            method_for_type: (o, exact=no) -> @method_for o?.prototype, exact

In addition to these introspection methods, the generic function also has
read-only properties for its dispatch argument position (``argn``), unique
name (``key``), and default method (``default_method``).

            argn, key, default_method
        }

## The Default Method

If you don't specify a default method when creating the generic function, it
defaults to raising ``simplegeneric.NoSuchMethod()``, which is a plain-vanilla
``Error`` subclass

    fail = -> throw new simplegeneric.NoSuchMethod()

    class simplegeneric.NoSuchMethod extends Error
        constructor: -> Error.apply(this, arguments)


## Property Definition

In addition to registering hidden methods on other objects, all of the
properties of generic functions themselves are defined using ES5 property
descriptors, where available.  (If ``Object.create()`` or
``Object.defineProperty()`` don't exist or throw errors, regular properties are
used instead.)

The internal ``defProp()`` and ``defProps()`` functions stand in for
``Object.defineProperty()`` and ``Object.defineProperties()``, respectively,
except that they only work with value properties (not getters or setters), and
they take any descriptor properties besides the ``value`` in the form of an
optional extra argument.

    defProp = (ob, key, value, opts) ->
        try
            opts ?= Object.create(null)
            opts.value = value
            Object.defineProperty ob, key, opts
        catch
            ob[key] = value
        return ob

    defProps = (ob, props, opts={}) ->
        for own key, value of props
            defProp ob, key, value, opts
        return ob














