import ../../src/prologue/core/byteRanges
import options

# TODO we need the file lengh to support
# "get last 500 byte" etc requests
doAssert ByteRange(startOpt: some(0) , stopOpt: some(0)).len == 1
doAssert ByteRange(startOpt: some(0), stopOpt: some(1023)).len == 1024
doAssert ByteRange(startOpt: some(0), stopOpt: some(499)).len == 500
doAssert ByteRange(startOpt: some(500), stopOpt: some(999)).len == 500

when false:
  import timeit
  template pp() =
    let ranges = parseByteRange("bytes=0-50, 100-150,0-50, 100-150,0-50, 100-150,0-50, 100-150,")
    doAssert ranges.len == 8
  echo timeGo(pp)

# Invalid byte ranges
block:
  doAssert parseByteRange("") == @[]
  doAssert parseByteRange("bytes=") == @[]
  doAssert parseByteRange("bytes") == @[]
  doAssert parseByteRange("byte") == @[]
  doAssert parseByteRange("bytes=,") == @[]
  doAssert parseByteRange("someInvalidStuff") == @[]

# Simple from-to ranges
block:
  let ranges = parseByteRange("bytes=0-499")
  doAssert ranges.len == 1
  doAssert ranges[0].len == 500
  doAssert ranges[0].startOpt.get() == 0
  doAssert ranges[0].stopOpt.get() == 499

block:
  let ranges = parseByteRange("bytes=0-50, 100-150")
  doAssert ranges.len == 2
  doAssert ranges[0].len == 51
  doAssert ranges[0].startOpt.get() == 0
  doAssert ranges[0].stopOpt.get() == 50
  doAssert ranges[1].len == 51
  doAssert ranges[1].startOpt.get() == 100
  doAssert ranges[1].stopOpt.get() == 150

block:
  let ranges = parseByteRange("bytes=50-100,200-250") # test robust parsing
  doAssert ranges.len == 2
  doAssert ranges[0].len == 51
  doAssert ranges[0].startOpt.get() == 50
  doAssert ranges[0].stopOpt.get() == 100
  doAssert ranges[1].len == 51
  doAssert ranges[1].startOpt.get() == 200
  doAssert ranges[1].stopOpt.get() == 250

block:
  let ranges = parseByteRange("bytes= 0-50 ,  100-150 ") # test robust parsing
  doAssert ranges.len == 2
  doAssert ranges[0].len == 51
  doAssert ranges[0].startOpt.get() == 0
  doAssert ranges[0].stopOpt.get() == 50
  doAssert ranges[1].len == 51
  doAssert ranges[1].startOpt.get() == 100
  doAssert ranges[1].stopOpt.get() == 150

# invalid integers
block:
  doAssert parseByteRange("bytes=999999999999999999999-9999999999999999999999") == @[] # test robust parsing

# trying to break parseing
block:
  doAssert parseByteRange("bytes= a-b ,  c-d ") == @[] # test robust parsing
  doAssert parseByteRange("bytes= a-b  asd  c-d ") == @[] # test robust parsing
  doAssert parseByteRange("bytes=-") == @[] # test robust parsing

  # TODO this should be invalid !!
  # doAssert parseByteRange("bytes=500--") == @[] # test robust parsing


  # TODO this should be invalid!!
  # echo parseByteRange("bytes= 10-ab cd ") # test robust parsing
  # doAssert parseByteRange("bytes= 10-ab cd ") == @[] # test robust parsing

  # TODO can this work? or should this be invalid?
  # doAssert parseByteRange("bytes=00--123") == @[] # test robust parsing

# more complex byte ranges
block:
  # A request for the last 500 bytes: bytes=-500
  let ranges = parseByteRange("bytes=-500")
  # echo "C1: ", ranges
  doAssert ranges.len == 1
  doAssert ranges[0].startOpt.isNone
  doAssert ranges[0].stopOpt.isSome
  doAssert ranges[0].stopOpt.get() == 500

block:
  # offset 501 bytes to the end ## TODO is it 500 or 501 bytes??
  let ranges = parseByteRange("bytes=500-")
  # echo "C1: ", ranges
  doAssert ranges.len == 1
  doAssert ranges[0].startOpt.isSome
  doAssert ranges[0].stopOpt.isNone
  doAssert ranges[0].startOpt.get() == 500

# block:
  # A request for the first and last byte: bytes=0-0,-1


# doAssert ByteRange(start: 0, stop: 1023).len == 1024

# IN:
# Range: bytes=0-1023
#
# OUT:
# """
# HTTP/1.1 206 Partial Content
# Content-Range: bytes 0-1023/146515
# Content-Length: 1024
# ...
# (binary content)
# """
#
# IN:
# Range: bytes=0-50, 100-150
#
# OUT:
# """
# HTTP/1.1 206 Partial Content
# Content-Type: multipart/byteranges; boundary=3d6b6a416f9b5
# Content-Length: 282
#
# --3d6b6a416f9b5
# Content-Type: text/html
# Content-Range: bytes 0-50/1270
#
# <!doctype html>
# <html>
# <head>
    # <title>Example Do
# --3d6b6a416f9b5
# Content-Type: text/html
# Content-Range: bytes 100-150/1270
#
# eta http-equiv="Content-type" content="text/html; c
# --3d6b6a416f9b5--
# """