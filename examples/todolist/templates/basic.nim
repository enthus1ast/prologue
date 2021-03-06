when not (compiles do: import karax / karaxdsl):
  {.error: "Please use `logue extension karax` to install!".}
else:
  import karax / [karaxdsl, vdom]


import strformat


proc makeList*(rows: seq[seq[string]]): string =
  let vnode = buildHtml(html):
    p: text "List items are as follows:"
    table(border = "1"):
      for row in rows:
        tr:
          for col in row:
            td: text col
  result = $vnode

proc editList*(id: int, value: seq[string]): string =
  let vnode = buildHtml(html):
    p: text fmt"Edit the task with ID = {id}"
    form(action = fmt"/edit/{id}", `method` = "get"):
      input(`type` = "text", name = "task", value = value[0], size = "100",
          maxlength = "80")
      select(name = "status"):
        option: text "open"
        option: text "closed"
      br()
      input(`type` = "submit", name = "save", value = "save")
  result = $vnode

proc newList*(): string =
  let vnode = buildHtml(html):
    p: text "Add a new task to the ToDo list:"
    form(action = "/new", `method` = "get"):
      input(`type` = "text", size = "100", maxlength = "80", name = "task")
      input(`type` = "submit", name = "save", value = "save")
  result = $vnode


when isMainModule:
  let t = makeList(@[@["1", "2", "3"], @["4", "6", "9"]])
  let e = editList(12, @["ok"])
  let n = newList()
  writeFile("todo.html", t)
  writeFile("edit.html", e)
  writeFile("new.html", n)
