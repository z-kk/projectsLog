import
  std / [strutils, sequtils, times, json],
  htmlgenerator,
  consts

proc makeInputTable*(): string =
  ## 入力欄テーブル作成
  var
    table: htable
    row: htr

  let titles = @["Proj.", "分類", "内容", "開始", "終了"]
  for title in titles:
    var th: hth
    th.content = title
    row.add th
  table.thead.add row

  let conf = ConfFile.parseFile

  let idx = table.tbody.rows.len

  var select: hselect
  select.name = "proj_" & $idx
  for key, _ in conf["projects"]:
    select.add hoption(content: key)
  row.add htd(content: select.toHtml)

  select.name = "cat_" & $idx
  select.options = @[]
  for cat in conf["categories"]:
    select.add hoption(content: cat.getStr)
  row.add htd(content: select.toHtml)

  var ipt: hinput
  ipt.name = "content_" & $idx
  row.add htd(content: ipt.toHtml)

  ipt.`type` = tpTime
  ipt.name = "from_" & $idx
  row.add htd(content: ipt.toHtml)

  ipt.name = "to_" & $idx
  row.add htd(content: ipt.toHtml)

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
  var
    body: hdiv
    frm: hform
    lbl: hlabel
    ipt: hinput

  lbl.content = "対象日: "
  ipt.`type` = tpDate
  ipt.name = "day"
  ipt.value = now().format("yyyy-MM-dd")
  frm.add lbl.toHtml
  frm.add ipt.toHtml
  frm.add Br
  frm.add Br

  var d: hdiv
  d.class.add "table"
  d.add makeInputTable()
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

  return makePage(body.toHtml, css, js)
