import
  std / [os, strutils, times, json],
  jester,
  makeHtml, dataUtils, consts

router rt:
  get "/":
    resp makeMainPage()
  get "/api/mermaid":
    var res = ""
    if GanttFile.fileExists:
      res = GanttFile.readFile
    resp res
  post "/api/update":
    let data = request.formData
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

    var res = infoList.updateLog
    if res["result"].getBool:
      res["body"] = %*data["day"].body.parse(DateFormat).makeInputTable
    resp res
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

proc startHttpServer*(port = 0) =
  var jest =
    if port < 1:
      rt.initJester
    else:
      let settings = newSettings(Port(port))
      rt.initJester(settings)
  jest.serve
