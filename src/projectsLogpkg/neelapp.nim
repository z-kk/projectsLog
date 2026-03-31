import
  std / [strutils, tables, times, json, htmlgen],
  neel,
  dataUtils, consts

export
  neel

proc makeDataList(name, cat: string): string =
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

proc mainPage(): string =
  ## MainPage
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

template startNeelApp*(dir = "assets", port = 5000, pos = [500, 150], siz = [600, 600], isApp = true) =
  ## Neel
  exposeProcs:
    proc initPage() =
      callJs "setNode", "main", mainPage()
      callJs "setEvent", true

    proc setDataList(data: JsonNode) =
      let
        name = data["proj"].getStr
        cat = data["category"].getStr
      callJs "setNode", "datalist", makeDataList(name, cat)

    proc updateLog(data: JsonNode) =
      try:
        updateData(data)
        callJs "setCalcTable"
        callJs "showDialog"
      except:
        callJs "showAlert", getCurrentExceptionMsg()

    proc updateInputTable(day: string) =
      callJs "setNode", "#inputtable", makeInputTable(day.parse(DateFormat))
      callJs "setEvent", false

    proc updateCalcTable(fDay: string, tDay: string) =
      callJs "setNode", "#calctable", makeCalcTable(fDay.parse(DateFormat), tDay.parse(DateFormat))

  startApp(webDirPath = dir, portNo = port, position = pos, size = siz, appMode = isApp)
