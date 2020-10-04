import parseutils
import options

type
  ByteRange* = object
    startOpt*: Option[int]
    stopOpt*: Option[int]

func len*(byteRange: ByteRange): int {.inline.} =
  ## Returns the bytes a byteRange Covers
  (byteRange.stopOpt.get() - byteRange.startOpt.get()) + 1

func readInt(str: string, pos: var int): Option[int] {.inline.} =
  var integer: uint
  let intLen = str.parseUInt(integer, pos) # TODO this should check somehow if the integer is wrong, then raise
  if intLen == 0:
    pos.inc
    return # no int here, no error, but no value
  pos +=  intLen
  return some(integer.int)


iterator parseRanges(str: string, pos: var int): ByteRange =
  while true:
    # debugEcho pos
    if pos >= str.len - 1: break
    pos += str.skipWhitespace(pos) # skip initial whitespaces

    var firstOpt: Option[int]
    if str[pos] != '-': # the first is omitted, skip to last
      try:
        firstOpt = str.readInt(pos)
      except:
        break # if parsing error occured, this one is invalid

    pos += str.skipWhitespace(pos) # skip whitespaces surrounding " - "
    pos += str.skip("-", pos)
    pos += str.skipWhitespace(pos)

    var secondOpt: Option[int]
    try:
      secondOpt = str.readInt(pos)
    except:
      break # if parsing error occured, this one is invalid

    # debugEcho "E ", first, " ", second
    if firstOpt.isSome or secondOpt.isSome:
      yield ByteRange(startOpt: firstOpt, stopOpt: secondOpt) # TODO choose correct int type

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