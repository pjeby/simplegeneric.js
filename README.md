# Single-Dispatch Generic Functions For JavaScript

This library provides a simple way to create single-dispatch generic functions in JavaScript, similar to Python's [simplegeneric](https://pypi.python.org/pypi/simplegeneric) and [functools.singledispatch](http://legacy.python.org/dev/peps/pep-0443/), but with a few JavaScript-specific twists.


## Usage

Create a generic function:

```javascript
var simplegeneric = require('simplegeneric');

var pprint = simplegeneric(
    // required first argument: globally unique name
    'com.myorg.myapp:pprint',

    // optional: argument number to dispatch on
    // (default = 0: first argument)
    0,

    // optional: default behavior
    // (if omitted, default throws simplegeneric.NoSuchMethod)                          
    function(ob, someArg, anotherArg){
        return ob.toString(); // code to handle default pprint operation
    }
)
```

Register implementations for various types:
 
```javascript
pprint.when_type(Number, function(ob, someArg, anotherArg) { 
    // code for pprinting a Number
})

pprint.when_type(MyClass, function(ob, someArg, anotherArg) { 
    // code for pprinting a MyClass instance
})
```

Call the generic function:

```javascript
pprint(43, someval, anotherval)           // calls code for pprinting a number
pprint(new MyClass(whatever), foo, bar)   // calls code for pprinting MyClass
pprint("whatever", baz, spam)             // calls default code
```

Register an implementation for one specific instance:

```javascript
pprint.when_object(someInstance, function(ob, someArg, anotherArg) { 
    // code for pprinting someInstance
    // (or anything that uses someInstance as its prototype)
})

pprint(someInstance, 99, 71)                        // calls someInstance code
pprint(Object.create(someInstance), "blah", eggs)   // also calls it 
pprint(Object.create(null), fidget, widget)         // calls default code
```

You can also ask a generic function for the method that would be used for objects of a particular type or instance, using the ``method_for(ob, exact=no)`` and ``method_for_type(ob, exact=no)`` methods, which return the registered function, if any, or an undefined value otherwise:

```javascript
pprint.method_for(23)               // returns number code
pprint.method_for_type(Number)      // likewise

pprint.method_for("x")              // undefined
pprint.method_for_type(String)      // undefined

pprint.method_for(someInstance)                 // someInstance code
pprint.method_for(Object.create(someInstance))  // someInstance code
```

Passing in an ``exact`` flag of ``true`` only returns a method if one was registered for the object or type passed in, ignoring ones registered for their base classes or prototypes:  

```javascript
pprint.method_for_type(Number, true)                  // number code
pprint.method_for(someInstance, true)                 // someInstance code
pprint.method_for(Object.create(someInstance), true)  // undefined!
```



## FAQ

### What's a Generic Function, anyway?

A generic function is an *extensible* function.  It replaces code that would otherwise be written as a large ``switch`` or series of ``if()`` statements, or as a bunch of methods spread out over a wide variety of classes (or prototypes in the case of JavaScript), and makes it possible for any module to define operations for certain types, without needing to modify the code of either the types or the original operation.

Instead, new types can register methods for existing operations, new operations can register methods for existing types, and application code can register methods to add support for the third-party types it uses, to a third-party operation it uses.

This lets you follow the [open/closed principle](http://en.wikipedia.org/wiki/Open/closed_principle) of software development: code should be open to extension, while being closed to modification.  A generic function can be extended at any time to add new types, without needing to modify its code.  And any type can be extended to support new generic functions, without needing to modify *its* code, either.  


### What good is that?

A generic function lets you organize your library or application code in terms of *operations*, instead of the objects being operated on.  If many different types might be involved, then the code for a specific operation might be spread out all over the place.  Sometimes, it's better to group the operations together for clarity, or because the operation is part of a different library than the tpes it operates on. 

Generic functions are especially useful when a library wants to offer a generally-useful operation for certain existing types, but it's not clear yet what it should do for new or third-party types.  For example, ``JSON.stringify()`` is a generic function, whose behavior can be extended by adding a ``toJSON()`` method to a new type.

In general, single-dispatch generic functions like the ones simplegeneric provides are also [a great replacement for the Visitor Pattern](http://peak.telecommunity.com/DevCenter/VisitorRevisited).


### Why not use a convention for method names instead?

That's actually what simplegeneric does, internally: the globally unique name (which should include an email address, URL, GUID, or other substring guaranteed to be unique) is used as a method name, and registered methods are attached to the right objects as non-enumerable properties.  (Unless you're running in a pre-ES5 environment; see [Compatibility](#compatibility), below.)

The main benefit of having simplegeneric do this instead of doing it directly is that your codebase stays DRY, *and* easy-to-read.  Instead of copying your unique name everywhere, or continually defining non-enumerable properties, your code just *says what it does*: it registers what e.g. ``pprint`` will do when given an object of a given type.


### But doesn't that mean depending on the module that exports the generic function, even in code that doesn't *call* it?

That's where the unique name comes in.  If you want to write a module that supports an operation on its types, but doesn't actually invoke the operation and thus shouldn't depend on the module where the operation is defined, you can simply create your own local generic function using the same unique name, and use *that* to register your implementations.

This lets you avoid pulling in the operation as a dependency, when you just want to support the operation on your types.

### But how will I know the unique name the other author used?

People writing libraries that want to support interop like this, should document the name they're using with their exported generic functions, and should change the name if the signature or requirements change, e.g. ``my.whatever.someOp:v1`` and ``my.whatever.someOp:v2``.

(In a pinch, you can also get the name from the ``.key`` property of the generic function, but if the author didn't document it, they may not intend for you to depend on it.  Check with them to be sure it'll stay supported!) 
 
## Compatibility <a name="compatibility"></a>

Functions created with this library should work correctly in any browser or JS engine, even back to IE 6.

On non-ES5 platforms (e.g. IE 8 and lower), however, registered methods will be enumerable, so you should avoid registering methods on individual objects with the ``.when_object()`` API, unless you know for sure that the enumerability will not be a problem.

This should usually not be an issue for methods registered with ``.when_type()``, since most code that enumerates object contents expects to use ``.hasOwnProperty()`` to filter out inherited methods.  But ``.when_object()`` will register methods directly on an instance, which can't be filtered out unless the properties are defined non-enumerable.

Using ``.when_object()`` on objects used only as prototypes should be safe, however, and all of these issues are moot if you are only targeting ES5 environments like Node, most non-IE browsers, and IE 9+.

## To Do

Docs:
* Add inline documentation for code & tests
* Add more examples

Open Questions:
* What does it really mean to be a "type" vs. prototype?
    * e.g. should objects that are already prototypes be accepted?
    * for ``method_for_type()`` as well as ``when_type()``? 
* Is some sort of ``super`` or ``next_method()`` API needed?

