import
  std / [os, strutils, sequtils, times, tables, json],
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
    logList = getLog(day, day)
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

proc makeCalcTable*(fromDay, toDay: DateTime): string =
  ## 集計テーブル作成
  let
    logList = getLog(fromDay, toDay)
    conf = ConfFile.parseFile
    ctg = conf["categories"].mapIt(it.getStr)

  var
    calc: Table[string, Table[string, Table[string, Duration]]]
    sum: Duration

  for log in logList:
    if not calc.hasKey(log.name):
      calc[log.name] = {log.category: {log.content: DurationZero}.toTable}.toTable
    if not calc[log.name].hasKey(log.category):
      calc[log.name][log.category] = {log.content: DurationZero}.toTable
    if not calc[log.name][log.category].hasKey(log.content):
      calc[log.name][log.category][log.content] = DurationZero

    var dur = log.toTime - log.fromTime
    for node in conf["restTime"]:
      let
        ftime = parse(log.fromTime.format(DateFormat) & " " & node["from"].getStr, DateTimeFormat)
        ttime = parse(log.fromTime.format(DateFormat) & " " & node["to"].getStr, DateTimeFormat)
      if ftime < log.toTime and log.fromTime < ttime:
        if ftime < log.fromTime:
          dur -= ttime - log.fromTime
        elif log.toTime < ttime:
          dur -= log.toTime - ftime
        else:
          dur -= ttime - ftime
    calc[log.name][log.category][log.content] += dur

  var
    table: htable
    row: htr

  let titles = @["Proj.", "分類", "時間", "Code", "内容"]
  for title in titles:
    row.add hth(content: title)
  table.thead.add row

  for key, node in conf["projects"]:
    if key in calc:
      for cat in ctg:
        if cat in calc[key]:
          for content, dur in calc[key][cat]:
            sum += dur
            row.add htd(content: key)
            row.add htd(content: cat)
            row.add htd(content: "$1:$2" %
              [dur.inHours.int.intToStr(2), dur.toParts[Minutes].int.intToStr(2)])
            row.add htd(content: node["code"].getStr)
            row.add htd(content: content)
            table.tbody.add row

  block sumRow:
    row.add htd()
    row.add htd(content: "合計")
    row.add htd(content: "$1:$2" %
      [sum.inHours.int.intToStr(2), sum.toParts[Minutes].int.intToStr(2)])
    row.add htd()
    row.add htd()
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
  ipt.value = today.format(DateFormat)
  frm.add lbl.toHtml
  frm.add ipt.toHtml
  frm.add Br
  frm.add Br

  var d: hdiv
  d.id = "inputtable"
  d.class.add "table"
  d.add today.makeInputTable
  frm.add d.toHtml

  # Popup
  frm.add hdiv(id: "lay").toHtml
  d = hdiv()
  d.id = "pop"
  lbl.content = "期間: "
  d.add lbl.toHtml
  ipt.`type` = tpDate
  ipt.id = "from_day"
  ipt.name = "from_day"
  ipt.value = today.format(DateFormat)
  d.add ipt.toHtml
  lbl.content = "～"
  d.add lbl.toHtml
  ipt.id = "to_day"
  ipt.name = "to_day"
  d.add ipt.toHtml
  d.add hbutton(type: tpButton, id: "updatebtn", content: "更新").toHtml
  d.add Br
  var ct: hdiv
  ct.id = "calctable"
  ct.class.add "table"
  ct.add makeCalcTable(today, today)
  d.add ct.toHtml
  frm.add d.toHtml

  body.add frm.toHtml

  body.add Br
  body.add hbutton(type: tpButton, id: "okbtn", content: "OK").toHtml

  if GanttFile.fileExists:
    body.add Br
    d = hdiv()
    d.id = "mermaid"
    d.class.add "mermaid"
    for line in GanttFile.lines:
      d.add line
    body.add d.toHtml
    body.add hbutton(type: tpButton, id: "mmdbtn", content: "更新").toHtml

  var
    css: seq[hlink]
    js: seq[hscript]
  css.add newLink("/popup.css")
  js.add newScript("/popup.js")
  js.add newScript("/main.js")

  js.add newScript("https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js")
  js.add newScript("/mermaid.js")

  return makePage(body.toHtml, css, js)
