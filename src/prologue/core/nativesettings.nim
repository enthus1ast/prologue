# Copyright 2020 Zeshen Xing
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


import mimetypes, json, tables, strtabs, os, strutils
from nativesockets import Port

from ./types import SecretKey, EmptySecretKeyError, len
from ./urandom import randomString


type
  Settings* = ref object     ## Global settings for all handlers.
    address*: string         ## The address of socket.
    port*: Port              ## The port of socket.
    debug*: bool             ## Debug mode(true is yes).
    reusePort*: bool         ## Use socket port in multiple times.
    staticDirs*: seq[string] ## The path of static directories.
    appName*: string         ## The name of your application.
    data: JsonNode

  CtxSettings* = ref object ## Context settings.
    mimeDB*: MimeDB
    config*: TableRef[string, StringTableRef]

  LocalSettings* = ref object ## local settings for corresponding handlers.
    data*: JsonNode


func hasKey*(settings: Settings, key: string): bool {.inline.} =
  ## Returns true if key is in `settings`.
  settings.data.hasKey(key)

func `[]`*(settings: Settings, key: string): JsonNode {.inline.} =
  ## Retreives value if key is in `settings`.
  settings.data[key]

func getOrDefault*(settings: Settings, key: string): JsonNode {.inline.} =
  ## Retreives value if key is in `settings`. Otherwise `nil` will be returned.
  settings.data.getOrDefault(key)

func newCtxSettings*(): CtxSettings {.inline.} =
  ## Creates a new context settings.
  CtxSettings(mimeDB: newMimetypes(), config: newTable[string, StringTableRef]())

func newLocalSettings*(data: JsonNode): LocalSettings {.inline.} =
  ## Creates a new local settings.
  result = LocalSettings(data: data)

proc newLocalSettings*(configPath: string): LocalSettings {.inline.} =
  ## Creates a new local settings.
  result = LocalSettings(data: parseFile(configPath))

func normalizedStaticDirs(dirs: openArray[string]): seq[string] =
  ## Normalizes the path of static directories.
  result = newSeqOfCap[string](dirs.len)
  for item in dirs:
    let dir = item.strip(chars = {'/'}, trailing = false)
    if dir.len != 0:
      result.add dir
    normalizePath(result[^1])

func newSettings*(address = "", port = Port(8080), debug = true, reusePort = true,
                  staticDirs: openArray[string] = [], secretKey = randomString(8),
                  appName = ""): Settings {.inline.} =
  ## Creates a new settings.
  if secretKey.len == 0:
    raise newException(EmptySecretKeyError, "Secret key can't be empty!")

  result = Settings(address: address, port: port, debug: debug, reusePort: reusePort,
                    staticDirs: normalizedStaticDirs(staticDirs), appName: appName,
                    data: %* {"secretKey": secretKey})

func newSettings*(data: JsonNode, address = "", port = Port(8080), debug = true, reusePort = true,
                  staticDirs: openArray[string] = [],
                  appName = ""): Settings {.inline.} =
  ## Creates a new settings.
  result = Settings(address: address, port: port, debug: debug, reusePort: reusePort,
                    staticDirs: normalizedStaticDirs(staticDirs), appName: appName,
                    data: data)

proc newSettings*(configPath: string, address = "", port = Port(8080), debug = true, reusePort = true,
                  staticDirs: openArray[string] = [],
                  appName = ""): Settings {.inline.} =
  ## Creates a new settings.
  # make sure reserved keys must appear in settings
  result = Settings(address: address, port: port, debug: debug, reusePort: reusePort,
                    staticDirs: normalizedStaticDirs(staticDirs), appName: appName,
                    data: parseFile(configPath))
