# Middlewares

## Write a middleware

Middleware is like an onion. 

a request -> middlewareA does something -> middlewareB does something
-> handler does something -> middlewareB does something -> middlewareA does something -> a response

Don't forget `await switch(ctx)` to enter next middleware or handler.

Then you can set global middlewares which are visible to all handlers. Or you can make them only
visible to some middlewares.

```nim
import logging
import prologue


proc hello(ctx: Context) {.async.} =
  discard

proc myDebugRequestMiddleware*(appName = "Starlight"): HandlerAsync =
  result = proc(ctx: Context) {.async.} =
    logging.info "debugRequestMiddleware->begin"
    # do something before
    await switch(ctx)
    # do something after
    logging.info "debugRequestMiddleware->End"


var
  settings = newSettings()
  app = newApp(settings = settings, middlewares = @[myDebugRequestMiddleware()])


app.addRoute("/", hello, HttpGet, middlewares = @[myDebugRequestMiddleware()])
```

You can also put some variables in closure environments, but be careful it is error-prone when using multi-threads. You must know the differences between gc options(thread local heap vs shared heap) and what's the use of `gcsafe`. 

```nim
proc sessionMiddleware(): HandleAsync =
  var memorySessionTable = newTable[string, string]()

  result = proc(ctx: Context) {.async.} =
    memorySessionTable["test"] = "prologue"
```

You can put your middleware plugin in [collections](https://github.com/planety/awesome-prologue).

## Use a middleware

`prologue` also supplies some middleware plugins, you can directly import them.

```nim
import prologue/middlewares
```

For better compilation time, you could import them directly.

```nim
import prologue/middlewares/signedcookiesession
# or
import prologue/middlewares/utils
# or
import prologue/middlewares/cors
```
