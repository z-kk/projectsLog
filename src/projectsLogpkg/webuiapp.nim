import
  std / [strutils, times, tables, json, htmlgen],
  webui,
  dataUtils, consts

proc makeDatalist(name, cat: string): string =
  ## 入力DataList
  for content in getContents(name, cat):
    result.add option(value = content)

proc makeInputTable(day: DateTime): string =
  ## ログ入力テーブル
  include "tmpl/inputTable.tmpl"

  let
    conf = ConfFile.parseFile
    log = getLog(day, day)

  return log.inputTable(conf)

proc makeCalcTable(fromDay, toDay: DateTime): string =
  ## 集計テーブル
  include "tmpl/calcTable.tmpl"

  let
    conf = ConfFile.parseFile
    log = getLog(fromDay, toDay)
  var
    calc: calcData

  for info in log:
    if info.name notin calc:
      calc[info.name] = {info.category: {info.content: DurationZero}.toTable}.toTable
    if info.category notin calc[info.name]:
      calc[info.name][info.category] = {info.content: DurationZero}.toTable
    if info.content notin calc[info.name][info.category]:
      calc[info.name][info.category][info.content] = DurationZero

    var dur = info.toTime - info.fromTime

    for node in conf["restTime"]:
      let
        ftime = parse("$1 $2" % [info.fromTime.format(DateFormat), node["from"].getStr], DateTimeFormat)
        ttime = parse("$1 $2" % [info.fromTime.format(DateFormat), node["to"].getStr], DateTimeFormat)
      if ftime < info.toTime and info.fromTime < ttime:
        if ftime < info.fromTime:
          dur -= ttime - info.fromTime
        elif info.toTime < ttime:
          dur -= info.toTime - ftime
        else:
          dur -= ttime - ftime
    calc[info.name][info.category][info.content] += dur

  return calc.calcTable(conf)

proc mainPage(e: Event): string =
  ## メインページ
  include "tmpl/main.tmpl"

  return mainPageBody(makeInputTable(now()))

proc updateData(data: JsonNode) =
  var infoList: seq[projInfo]
  for row in data["rows"]:
    var info: projInfo
    info.name = row["proj"].getStr
    info.category = row["cat"].getStr
    info.content = row["content"].getStr
    if info.content == "":
      continue
    try:
      info.fromTime = parse("$1 $2" % [data["day"].getStr, row["fromTime"].getStr], DateTimeFormat)
      info.toTime = parse("$1 $2" % [data["day"].getStr, row["toTime"].getStr], DateTimeFormat)
    except:
      continue

    infoList.add info

  infoList.updateLog

proc startwebui*() =
  let w = newWindow()

  w.rootFolder = "public"

  w.bind("mainPage", mainPage)

  w.bind("inputTable") do (e: Event) -> string:
    result = makeInputTable(e.getString.parse(DateFormat))

  w.bind("calcTable") do (e: Event) -> string:
    result = makeCalcTable(e.getString(0).parse(DateFormat), e.getString(1).parse(DateFormat))

  w.bind("dataList") do (e: Event) -> string:
    let data = e.getString.parseJson
    result = makeDatalist(data["proj"].getStr, data["category"].getStr)

  w.bind("updateLog") do (e: Event):
    let data = e.getString.parseJson
    try:
      data.updateData
      e.window.run("setCalcTable();")
    except:
      w.run("showAlert('$1');" % [getCurrentExceptionMsg()])

  w.show("index.html")
  w.run("init();")

  wait()
  clean()
