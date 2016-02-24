---
title:  "Go serialization"
date:   2015-05-29
tags: [Go]
---

I have been using Golang to build some REST API recently, and I was having some trouble to serialize my data properly to JSON.

Almost all tutorial around there tell about how we should return JSON, using some `struct` and tags.

```go
type User struct {
    ID        int `json:"id"`
    Email     string `json:"email"`
    HideEmail bool `json:"hide_email"`
    FirstName string `json:"first_name"`
    LastName  string `json:"last_name"`
    CreatedAt time.Time `json:"created_at"`
    UpdatedAt time.Time `json:"updated_at"`
}

user := User{
    ID: 1, Email: "x@example.com", FirstName: "Foo", LastName:  "Bar",HideEmail: true
}

data, err := json.Marshal(user)
```

This is indeed useful, but there are many cases when we want to dynamically choose what to serialize depending some privacy settings, whether the user is logged in or not, or a lot of other factors.

For these situations, I found it a bit verbose and repetitive to have to enter each field in a `map` to be able to have the wanted serialization output, so I decided to create a little library to help me do this. Its goal is basically to help converting a `struct` to a `map` with the most flexibility as possible.

With the above `struct`, given I want to hide the `Email` field when `HideEmail` is true, I can write:

```go
userSerializer := structomap.New().
                             UseSnakeCase().
                             Pick("ID", "Email", "FirstName", "LastName").
                             Omit("HideEmail").
                             OmitIf(func(u interface{}) bool {
                                return u.(User).HideEmail
                            }, "Email")
```

and then I just need to call `userSerializer.Transform` on any user to get the result I want as a `map[string]interface{}`. What is nice about this is that it also works with arrays: `userSerializer.TransformArray` will transform an array of `User` in an array of `map[string]interface{}` which can be directly serialized to JSON.

You can find more information on [the project page](https://github.com/tuvistavie/structomap).
