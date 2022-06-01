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
