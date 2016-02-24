---
title:  "Optional parameters and decorators in JavaScript"
date:   2015-01-03
tags: [JavaScript]
---

Optional parameters is a widely used programming pattern and
is available by default in many languages. For example, an
example in Python could be:

```python
def my_function(required_parameter, optional_parameter=None):
    print(optional_parameter)  # will be None if not passed
```

It is easy enough with most languages, but when it comes to Javascript,
an issue we have is that the last parameter is usually used for the callback,
so a lot of functions look like

```javascript
function (requiredParameter, optionalParameter, callback) {
}
```

so the callback can be either the second or the third parameter,
depending wether the optional parameter is provided or not.
There are a lot of ways to check if the optional parameter is
present, assign it a default value if not, and assign the callback
to the right argument.

The simplest way to do this could be:

```javascript
function (requiredParameter, optionalParameter, callback) {
  if (arguments.length <= 2)
    callback = optionalParameter;
    optionalParameter = {}; // default value
  }
}
```

Another common way is to use a real array for the arguments:

```javascript
function(err, optionalA, optionalB, callback) {
  var args = [];
  for (var i = 0; i < arguments.length; i++) {
      args.push(arguments[i]);
  }
  err = args.shift();
  callback = args.pop();
  if (args.length > 0)
    optionalA = args.shift();
  else
    optionalA = {}; // default value
  if (args.length > 0)
    optionalB = args.shift();
  else
    optionalB = {}; // default value
}
```

This can become a mess quite easily and is too repetitive.

# Using a decorator

There are many solutions to come over this lack of DRYness
and have things working more easily.
Some libraries take the `arguments` of the function and
wrap it in an easy to use object.

Here, I am going to present a solution using a decorator,
which have the advantage that the functions can be written
just as always, without having to check for the parameters
anymore.

We are here going to write a function which has the following
behavior:

* The first argument is the number of required arguments of the function
* The last argument is the function to decorate
* The arguments in between are the default values for the optional parameters
* The return value is the decorated function

For example, we should get the following result:

```javascript
var myFunction = wrapIt(1, "default", {}, function (requiredParameter, optionalString, optionalObject, callback) {
  console.log(requiredParameter);
  console.log(optionalString);
  console.log(optionalObject);
  if (callback) callback();
});

var callback = function () {
  console.log("calling callback");
};

myFunction("req", callback);
// will print:
// req
// default
// {}
// calling callback

myFunction("req", "mystring", callback);
// will print:
// req
// mystring
// {}
// calling callback

myFunction("req", "mystring", {a: 1}, callback);
// will print:
// req
// mystring
// {a: 1}
// calling callback
```

We are now going to implement this decorator.
Let's start with a decorator that just call
its last argument, without any modifications to the arguments.

```javascript
var wrapIt = function () {
  var baseArgs = [];
  baseArgs.push.apply(baseArgs, arguments); // transform the arguments into an array
  var decorated = baseArgs.pop();
  return function () {
    return decorated.apply(this, arguments);
  };
};
```

This function can be called as the one provided in the above example,
but will not modify the arguments. We now need to transform the `arguments`
to leave the required parameters as are, and then assign the defaults values
if the optional parameters are not present.

```javascript
var wrapIt = function () {
  var baseArgs = [];
  baseArgs.push.apply(baseArgs, arguments); // transform the arguments into an array
  var requiredArgsCount = baseArgs.shift();
  var decorated = baseArgs.pop();

  return function () {
    if (arguments.length < requiredArgsCount) {
      return decorated.apply(this, arguments);
    }

    return decorated.apply(this, arguments);
  };
};
```

Here, we get the number of required arguemnts in the first parameter, and
then leave only the default values for optional parameters in `baseArgs`.
When the required arguments are not provided, the behavior is not predictable,
so we just call the function without further processing.
Finally, we just need to build the array for the decorated function arguments
with either the provided parameter or with the default value.

```javascript
var wrapIt = function () {
  var baseArgs = [];
  baseArgs.push.apply(baseArgs, arguments);
  var requiredArgsCount = baseArgs.shift();
  var decorated = baseArgs.pop();

  return function () {
    if (arguments.length < requiredArgsCount) {
      return decorated.apply(this, arguments);
    }

    var i;
    var args = [];
    args.push.apply(args, arguments);

    var decoratedArgs = [];
    var cb = null;

    if (typeof args[args.length - 1] === 'function') {
      cb = args.pop();
    }

    for (i = 0; i < requiredArgsCount; i++) {
      decoratedArgs.push(args.shift());
    }

    for (i = 0; i < baseArgs.length; i++) {
      if (args[i]) {
        decoratedArgs.push(args[i]);
      } else {
        decoratedArgs.push(baseArgs[i]);
      }
    }

    decoratedArgs.push(cb);

    return decorated.apply(this, decoratedArgs);
  };
}
```

We extract the last argument, which should be the callback, only if it is a function.
Then, we push all the required arguments into the decorated function arguments,
we then push the optional arguments or their default value, and finally we push
the callback at the end of the array. We then call the decorated function with
the built arguments array.

This should work for all the cases in the example above, and provides an easy way to
work with optional parameters.

I have published this small code with proper tests as a package working for browser and NodeJS.
It is available at: [https://github.com/tuvistavie/js-easy-params](https://github.com/tuvistavie/js-easy-params).
