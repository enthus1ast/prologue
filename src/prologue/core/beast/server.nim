import strtabs


import asyncdispatch
from ./request import NativeRequest
from ../nativesettings import Settings, CtxSettings
from ../context import Router, ReversedRouter, ReRouter, HandlerAsync,
    Event, ErrorHandlerTable, GlobalScope

import httpx except Settings, Request


type
  Prologue* = ref object
    gScope*: GlobalScope
    middlewares*: seq[HandlerAsync]
    startup*: seq[Event]
    shutdown*: seq[Event]
    errorHandlerTable*: ErrorHandlerTable

proc serve*(app: Prologue, port: Port,
            callback: proc (request: NativeRequest): Future[void] {.closure, gcsafe.},
            address = "", numThreads = 0) {.inline.} =
  ## Serves a new web application.
  run(callback, httpx.initSettings(port, address, numThreads))

func newPrologue*(settings: Settings, ctxSettings: CtxSettings, router: Router,
                  reversedRouter: ReversedRouter, reRouter: ReRouter, middlewares: seq[HandlerAsync], 
                  startup: seq[Event], shutdown: seq[Event],
                  errorHandlerTable: ErrorHandlerTable, appData: StringTableRef): Prologue {.inline.} =
  ## Creates a new application instance.
  Prologue(gScope: GlobalScope(settings: settings, ctxSettings: ctxSettings, router: router, 
           reversedRouter: reversedRouter, reRouter: reRouter, appData: appData),
           middlewares: middlewares, startup: startup, shutdown: shutdown,
           errorHandlerTable: errorHandlerTable)
