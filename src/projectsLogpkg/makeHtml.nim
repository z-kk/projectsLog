import
  std / [strutils, sequtils, times, json],
  htmlgenerator,
  dataUtils, consts

proc makeInputRow(info: projInfo, idx: int): htr =
  ## 入力欄行作成
  let
    conf = ConfFile.parseFile
  var
    select: hselect
    ipt: hinput

  select.class = @["proj"]
  select.name = idx.projStr
  for key, _ in conf["projects"]:
    var option = hoption(content: key)
    if key == info.name:
      option.selected = true
    select.add option
  result.add htd(content: select.toHtml)

  select.class = @["cat"]
  select.name = idx.catStr
  select.options = @[]
  for cat in conf["categories"]:
    var option = hoption(content: cat.getStr)
    if cat.getStr == info.category:
      option.selected = true
    select.add option
  result.add htd(content: select.toHtml)

  ipt.class = @["content"]
  ipt.name = idx.contentStr
  ipt.value = info.content
  result.add htd(content: ipt.toHtml)

  ipt.`type` = tpTime
  ipt.class = @["fromTime"]
  ipt.name = idx.fromStr
  if info.fromTime != DateTime():
    ipt.value = info.fromTime.format("HH:mm")
  result.add htd(content: ipt.toHtml)

  ipt.class = @["toTime"]
  ipt.name = idx.toStr
  if info.toTime != DateTime():
    ipt.value = info.toTime.format("HH:mm")
  result.add htd(content: ipt.toHtml)

proc makeInputTable*(day: DateTime): string =
  ## 入力欄テーブル作成
  let
    logList = getLog(day, day + 1.days)
  var
    table: htable
    row: htr

  let titles = @["Proj.", "分類", "内容", "開始", "終了"]
  for title in titles:
    row.add hth(content: title)
  table.thead.add row

  var idx: int
  for log in logList:
    row = log.makeInputRow(idx)
    table.tbody.add row
    idx.inc

  row = projInfo().makeInputRow(idx)
  table.tbody.add row

  return table.toHtml

proc makePage(body = "", css: seq[hlink] = @[], js: seq[hscript] = @[], title = ""): string =
  ## ページ作成
  var
    head: hhead
    meta: hmeta

  head.title = title
  meta.charset = "utf-8"
  head.add meta
  for c in css:
    head.add c
  head.add newScript("/functions.js")

  return """
    <!DOCTYPE html>
    <html lang="ja">
      $1
      <body>
        $2
      </body>
      $3
    </html>
  """.dedent % [head.toHtml, body, js.mapIt(it.toHtml).join("\n")]

proc makeMainPage*(): string =
  ## メインページ作成
  let
    today = now()
  var
    body: hdiv
    frm: hform
    lbl: hlabel
    ipt: hinput

  lbl.content = "対象日: "
  ipt.`type` = tpDate
  ipt.id = "day"
  ipt.name = "day"
  ipt.value = today.format("yyyy-MM-dd")
  frm.add lbl.toHtml
  frm.add ipt.toHtml
  frm.add Br
  frm.add Br

  var d: hdiv
  d.class.add "table"
  d.add today.makeInputTable
  frm.add d.toHtml

  d = hdiv()
  d.id = "pop"
  frm.add hdiv(id: "lay").toHtml
  frm.add d.toHtml

  body.add frm.toHtml

  body.add Br
  body.add hbutton(type: tpButton, id: "okbtn", content: "OK").toHtml

  var
    css: seq[hlink]
    js: seq[hscript]
  css.add newLink("/popup.css")
  js.add newScript("/popup.js")
  js.add newScript("/main.js")

  return makePage(body.toHtml, css, js)
