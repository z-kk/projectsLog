import
  std / [strutils, sequtils, times, json],
  jester, htmlgenerator,
  dataUtils, taskdata, utils, consts

type
  Page = enum
    pgMain = "/"

const
  AppTitle = "ProjLog"

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

proc mainPage(): seq[string] =
  ## メインページ
  include "tmpl/main.tmpl"

  let
    today = now()
    iptTable = makeInputTable(today).splitLines
    calTable = makeCalcTable(today, today).splitLines

  return mainPageBody(iptTable, calTable).splitLines

proc makePage(req: Request, page: Page): string =
  include "tmpl/base.tmpl"

  var param = req.newParams
  param.title = AppTitle

  case page
  of pgMain:
    param.lnk.add req.newLink("popup.css").toHtml
    param.body = mainPage()
    param.script.add req.newScript("popup.js").toHtml
    param.script.add req.newScript("taskdata.js").toHtml
    param.script.add req.newScript("main.js").toHtml

  return param.basePage

proc updateData(req: Request): JsonNode =
  result = %*{"result": false, "err": "unknown error"}

  let
    data = req.formData
  var
    infoList: seq[projInfo]
    idx: int
  while idx.projStr in data:
    var info: projInfo
    info.name = data[idx.projStr].body
    if not (idx.catStr in data):
      break
    info.category = data[idx.catStr].body
    if not (idx.contentStr in data):
      break
    info.content = data[idx.contentStr].body
    if not (idx.fromStr in data) or data[idx.fromStr].body == "":
      break
    info.fromTime = parse("$1 $2" % [data["day"].body, data[idx.fromStr].body], DateTimeFormat)
    if not (idx.toStr in data) or data[idx.toStr].body == "":
      break
    info.toTime = parse("$1 $2" % [data["day"].body, data[idx.toStr].body], DateTimeFormat)

    infoList.add info
    idx.inc

  try:
    infoList.updateLog
    return %*{
      "result": true,
      "body": data["day"].body.parse(DateFormat).makeInputTable,
    }
  except:
    result["err"] = %getCurrentExceptionMsg()

proc updateTask(req: Request): JsonNode =
  ## Update task data.
  result = %*{
    "result": false,
    "err": "unknown error",
  }

  let json = req.body.parseJson
  var data: TaskData
  data.uuid = json["uuid"].getStr
  data.proj = json["proj"].getStr
  data.title = json["title"].getStr
  case TaskStatus(json["status"].getStr.parseInt)
  of Pending: discard
  of Doing: data.start
  of Waiting: data.wait(json["for"].getStr.parse(DateFormat))
  of Hide: data.hide(json["for"].getStr.parse(DateFormat))
  of Done: data.done
  if "due" in json:
    data.due = json["due"].getStr.parse(DateFormat)

  var target = @[data]
  if "parent" in json:
    var parent = getTaskData()[json["parent"].getStr]
    if data.uuid notin parent.children:
      parent.children.add data.uuid
    target.add parent

  target.commit
  return %*{
    "result": true,
    "data": getTaskData().toJson,
  }

proc deleteTask(req: Request): JsonNode =
  ## Delete task data.
  result = %*{
    "result": false,
    "err": "unknown error",
  }

  let
    data = getTaskData()
    uuid = req.body.parseJson["uuid"].getStr
  if uuid in data:
    data[uuid].delete
    return %*{
      "result": true,
      "data": getTaskData().toJson,
    }
  else:
    result["err"] = %"uuid not in task"

router rt:
  get "/":
    resp request.makePage(pgMain)
  get "/api/taskdata":
    resp getTaskData().toJson
  post "/api/update":
    resp request.updateData
  post "/api/updatetask":
    resp request.updateTask
  post "/api/deletetask":
    resp request.deleteTask
  post "/api/getinputtable":
    let data = request.formData
    resp data["day"].body.parse(DateFormat).makeInputTable
  post "/api/getcalctable":
    let data = request.formData
    var f, t = now()
    if "from_day" in data:
      f = data["from_day"].body.parse(DateFormat)
    if "to_day" in data:
      t = data["to_day"].body.parse(DateFormat)
    resp makeCalcTable(f, t)
  post "/api/getcontents":
    let data = request.formData
    var name, cat: string
    if "proj" in data:
      name = data["proj"].body
    if "category" in data:
      cat = data["category"].body
    resp getContents(name, cat).join("\n")

proc startWebServer*(port = 0) =
  var jest =
    if port < 1:
      rt.initJester
    else:
      let settings = newSettings(Port(port))
      rt.initJester(settings)
  jest.serve
