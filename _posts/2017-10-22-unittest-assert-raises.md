---
layout: post
title: assertRaises in Python
tags: [Python, unittest]
---

In this blog post, we will cover how `assertRaises` in `unittest.TestCase` works and implement a simplified version of it.
For the sake of example, let's say we want to check that `next(iter([]))` raises a `StopIteration` error. We will use a very simple Python script to try the code

```python
import unittest

class SampleTest(unittest.TestCase):
    def test_assert_raises(self):
        pass

if __name__ == '__main__':
    unittest.main()
```

### Common mistake

First, let's think about a typical error when trying to use `self.assertRaises`.
Let's replace the `pass` with the following statement.

```python
self.assertRaises(StopIteration, next(iter([])))
```

Python evaluation is strict, which means that when evaluating the above expression, it will first evaluate all the arguments, and after evaluate the method call. When evaluating the arguments we passed in, `next(iter([]))` will raise a `StopIteration` and `assertRaises` will not be able to do anything about it, even though we were hoping to make our assertion. We will therefore end up with the test failing because of this exception.

So, there are two ways implemented by `assertRaises` to go around this issue.

### Function call delegation approach

The first way is to delegate the call of the function raising the exception to `assertRaises` directly. This means that we pass a reference to the function we would like to call and all its arguments to `assertRaises`, and let it take care of calling the function we passed in. `assertRaises` will ensure that the exception is captured when making the function call.
The call looks like this

```python
self.assertRaises(StopIteration, next, iter([]))
```

`next` is the function we want to call and `iter([])` are the arguments to this function.
We can try it in the above call and the test will pass, as expected.
To see how this might work, here is a sample implementation of `assertRaises` that can be called in the same way. Note that it is not implemented exactly in this way in the `unittest` module.

```python
def argsAssertRaises(self, exc_type, func, *args, **kwargs):
    raised_exc = None
    try:
      func(*args, **kwargs)
    except exc_type as e:
      raised_exc = e
    if not raised_exc:
      self.fail("{0} was not raised".format(exc_type))
```

There are three possible outcomes here:

* If `func` raises `exc_type`, it will be caught, `raised_exc` will not be `None` anymore, and the function will terminate successfully
* If nothing is raised, `raised_exc` will stay `None` and `self.fail` will be called
* If another exception is raised, it will not be caught as we are only catching `exc_type`.

which is the expected behavior. You can try replacing `self.assertRaises` by `self.argsAssertRaises` and it should give the same result.

### Context manager approach

The other way that `unittest` uses to assert on exceptions is by using [context managers][1].

A sample usage would look like this

```python
with self.assertRaises(StopIteration):
    next(iter([]))
```

To understand how it might work, there are a few things we need to understand about context managers.
A context manager is typically used as

```python
with MyContextManager() as m:
    do_something_with(m)
```

The identifier in the `as` clause will be assigned whatever the `__enter__` method of `MyContextManager` returns. When the `with` statement exits, it will call the `__exit__` method of `MyContextManager`, potentially passing in the exception type, exception value and exception traceback - respectively `exc_type`, `exc_value` and `exc_tb`. If an exception has been raised and the `__exit__` method returns `True`, the exception is suppressed, otherwise, the exception will propagate.

Once we understand this, this gives us some idea about how we could implement `assertRaises`:

* `assertRaises` should return a context manager instance - i.e. the instance of a class implementing `__enter__` and `__exit__`
* `__enter__` does not seem very important here, as we are not using the `as` clause anywhere
* `__exit__` should check if the passed exception has been raised, in which case it should suppress it

Here is a simple implementation of a context manager doing this.

```python
class SampleRaiseContextManager:
    def __init__(self, expected_exc, test_case):
        self.expected_exc = expected_exc
        self.test_case = test_case

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_value, tb):
        if exc_type is None:
            self.test_case.fail("{0} was not raised".format(self.expected_exc))
        elif isinstance(exc_value, self.expected_exc):
            return True
        return False
```

`expected_exc` is the type of the exception we are expecting, and `test_case`
is the current test case - `self` in our `TestCase` methods. In `__enter__`,
we simply return `self`, although we are not doing anything useful with it here.
The important part here is `__exit__`. If `exc_type` is `None`, it means that
nothing was raised inside the `with` statement, so we want to fail the test case
as we were expecting an exception. If we did not enter this clause,
we are sure that an exception has been raised, so we want to check if it
was the exception we were expecting. This is done by using `isinstance` on the value of the raised exception. If the exception we were expecting has been raised, we
suppress it, as we want the test to succeed. Otherwise, it means that
an unexpected exception was raised, so we let it propagate.

Now that we have our context manager, we simply need to write a helper method
in our test case class, which will return an instance of it:

```python
def cmAssertRaises(self, expected_exc):
    return SampleRaiseContextManager(expected_exc, self)
```

we can now use our helper method to test for exceptions

```python
with self.cmAssertRaises(StopIteration):
    next(iter([]))
```

This is pretty much it for how `assertRaises` works.
Here is the full Python code for the explanations above

```python
import unittest


class SampleRaiseContextManager:
    def __init__(self, expected_exc, test_case):
        self.expected_exc = expected_exc
        self.test_case = test_case

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_value, tb):
        if exc_type is None:
            self.test_case.fail("{0} was not raised".format(self.expected_exc))
        elif isinstance(exc_value, self.expected_exc):
            return True
        return False


class SampleTest(unittest.TestCase):
    def test_args_raise(self):
        self.argsAssertRaises(StopIteration, next, iter([]))

    def test_my_context_manager(self):
        with self.cmAssertRaises(StopIteration):
            next(iter([]))

    def argsAssertRaises(self, exc_type, func, *args, **kwargs):
        raised_exc = None
        try:
            func(*args, **kwargs)
        except exc_type as e:
            raised_exc = e
        if not raised_exc:
            self.fail("{0} was not raised".format(exc_type))

    def cmAssertRaises(self, exc_type):
        return SampleRaiseContextManager(exc_type, self)


if __name__ == '__main__':
    unittest.main()
```


The only part left is to unify the two implementations above - `argsAssertRaises` and `cmAssertRaises`. This can be done by receiving a variable number of arguments and checking the number of arguments received.

Of course, the code above is for learning purpose, so for real world use cases, use the implementation provided by the `unittest` module.


[1]: https://docs.python.org/3/library/stdtypes.html#typecontextmanager
