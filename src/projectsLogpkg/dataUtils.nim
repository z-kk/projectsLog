import
  std / [strutils, times, json],
  consts, dbtables

type
  projInfo* = object
    name*: string
    category*: string
    content*: string
    fromTime*: DateTime
    toTime*: DateTime

proc updateLog*(infoList: seq[projInfo]): JsonNode =
  ## ログデータを登録
  result = %*{ "result": true }
  if infoList.len == 0:
    return
  let
    db = openDb()
    conf = ConfFile.parseFile
  if db.selectLogTable("day = '$1'" % [infoList[0].fromTime.format(DateFormat)]).len > 0:
    db.exec("delete from log where day = ?".sql, infoList[0].fromTime.format(DateFormat))
  for info in infoList:
    let proj = conf["projects"][info.name]
    var log: LogTable
    log.project_id = proj["id"].getInt
    log.project_code = proj["code"].getStr
    log.day = info.fromTime.format(DateFormat).parse(DateFormat)
    log.category = info.category
    log.content = info.content
    log.from_time = info.fromTime
    log.to_time = info.toTime
    log.updated_at = now()
    try:
      db.insertLogTable(log)
    except:
      return %*{ "result": false, "exception": getCurrentExceptionMsg() }

proc getLog*(fromDay, toDay: DateTime): seq[projInfo] =
  ## ログデータを取得
  let
    db = openDb()
    conf = ConfFile.parseFile
    res = db.selectLogTable("day >= '$1' AND day <= '$2'" %
      [fromDay.format(DateFormat), (toDay + 1.days).format(DateFormat)])
  for row in res:
    var info: projInfo
    for key, node in conf["projects"]:
      if node["id"].getInt != row.project_id:
        continue
      info.name = key
      break
    info.category = row.category
    info.content = row.content
    info.fromTime = row.from_time
    info.toTime = row.to_time
    result.add info
