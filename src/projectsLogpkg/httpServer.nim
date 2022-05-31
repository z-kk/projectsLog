import
  std / [strutils, times],
  jester,
  makeHtml, dataUtils, consts

router rt:
  get "/":
    resp makeMainPage()
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

    resp infoList.updateLog

proc startHttpServer*(port = 0) =
  var jest =
    if port < 1:
      rt.initJester
    else:
      let settings = newSettings(Port(port))
      rt.initJester(settings)
  jest.serve
