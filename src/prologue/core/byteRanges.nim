import parseutils

type
  ByteRange* = object
    start*: uint
    stop*: uint

func len*(byteRange: ByteRange): uint {.inline.} =
  ## Returns the bytes a byteRange Covers
  (byteRange.stop - byteRange.start) + 1



iterator parseRanges(str: string, pos: var int): ByteRange =
  while true:
    if pos >= str.len - 1: break
    pos += str.skipWhitespace(pos) # skip initial whitespaces

    var first: int = 0
    try:
      let intLen = str.parseInt(first, pos)
      if intLen == 0: break
      pos +=  intLen
    except:
      debugEcho "invalid byte range, first"
      break
    debugEcho "FIRST: ", first

    pos += str.skipWhitespace(pos) # skip whitespaces surrounding " - "
    pos += str.skip("-", pos)
    pos += str.skipWhitespace(pos)

    var second: int = 0
    try:
      let intLen = str.parseInt(second, pos)
      if intLen == 0: break
      pos +=  intLen
    except:
      debugEcho "invalid byte range, second"
      break
    debugEcho "E ", first, " ", second

    yield ByteRange(start: first.uint, stop: second.uint) # TODO choose correct int type
    pos += str.skipWhitespace(pos) # skip whitespaces surrounding " , "
    pos += str.skip(",", pos)
    pos += str.skipWhitespace(pos)


func parseByteRange*(str: string): seq[ByteRange] =
  ## parses a `Content-Range: bytes` request,
  if str.len == 0: return @[]
  var pos = 0
  pos += str.skipWhitespace(pos)
  var rangeUnit: string = ""
  pos += str.parseUntil(rangeUnit, '=', pos)
  pos.inc # skip =
  if rangeUnit != "bytes":
    debugEcho "invalid byte range unit: " & rangeUnit
    return @[] # we do not support any other range unit than byte
  if pos == str.len:
    debugEcho "we've parsed the whole string already, invalid byte range"
    return @[] # we've parsed the whole string already, invalid byte range
  for byteRange in str.parseRanges(pos):
    result.add byteRange