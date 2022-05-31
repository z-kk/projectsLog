import
  os, strutils, strformat, parsecsv,
  times,
  db_sqlite
type
  LogCol* {.pure.} = enum
    id, project_id, project_code, day, from_time, to_time, updated_at
  LogTable* = object
    primKey: int
    id*: int
    project_id*: int
    project_code*: string
    day*: DateTime
    from_time*: DateTime
    to_time*: DateTime
    updated_at*: DateTime
proc setDataLogTable*(data: var LogTable, colName, value: string) =
  case colName
  of "id":
    try:
      data.id = value.parseInt
    except: discard
  of "project_id":
    try:
      data.project_id = value.parseInt
    except: discard
  of "project_code":
    try:
      data.project_code = value
    except: discard
  of "day":
    try:
      data.day = value.parse("yyyy-MM-dd HH:mm:ss")
    except: discard
  of "from_time":
    try:
      data.from_time = value.parse("yyyy-MM-dd HH:mm:ss")
    except: discard
  of "to_time":
    try:
      data.to_time = value.parse("yyyy-MM-dd HH:mm:ss")
    except: discard
  of "updated_at":
    try:
      data.updated_at = value.parse("yyyy-MM-dd HH:mm:ss")
    except: discard
proc createLogTable*(db: DbConn) =
  let sql = """create table if not exists log(
    id INTEGER not null primary key,
    project_id INTEGER not null,
    project_code TEXT,
    day DATETIME default '9999-12-31' not null,
    from_time DATETIME not null,
    to_time DATETIME not null,
    updated_at DATETIME default '9999-12-31' not null
  )""".sql
  db.exec(sql)
proc insertLogTable*(db: DbConn, rowData: LogTable) =
  var sql = "insert into log("
  if rowData.id > 0:
    sql &= "id,"
  sql &= """project_id,project_code,day,from_time,to_time,updated_at
    ) values ("""
  if rowData.id > 0:
    sql &= &"{rowData.id},"
  sql &= &"{rowData.project_id},'{rowData.project_code}',datetime('" & rowData.day.format("yyyy-MM-dd HH:mm:ss") & &"'),datetime('" & rowData.from_time.format("yyyy-MM-dd HH:mm:ss") & &"'),datetime('" & rowData.to_time.format("yyyy-MM-dd HH:mm:ss") & &"'),datetime('" & rowData.updated_at.format("yyyy-MM-dd HH:mm:ss") & &"')"
  sql &= ")"
  db.exec(sql.sql)
proc insertLogTable*(db: DbConn, rowDataSeq: seq[LogTable]) =
  for rowData in rowDataSeq:
    db.insertLogTable(rowData)
proc selectLogTable*(db: DbConn, whereStr = "", orderStr = ""): seq[LogTable] =
  var sql = "select * from log"
  if whereStr != "":
    sql &= " where " & whereStr
  if orderStr != "":
    sql &= " order by " & orderStr
  let rows = db.getAllRows(sql.sql)
  for row in rows:
    var res: LogTable
    res.primKey = row[LogCol.id.ord].parseInt
    res.setDataLogTable("id", row[LogCol.id.ord])
    res.setDataLogTable("project_id", row[LogCol.project_id.ord])
    res.setDataLogTable("project_code", row[LogCol.project_code.ord])
    res.setDataLogTable("day", row[LogCol.day.ord])
    res.setDataLogTable("from_time", row[LogCol.from_time.ord])
    res.setDataLogTable("to_time", row[LogCol.to_time.ord])
    res.setDataLogTable("updated_at", row[LogCol.updated_at.ord])
    result.add(res)
proc updateLogTable*(db: DbConn, rowData: LogTable) =
  if rowData.primKey < 1: return
  var sql = "update log set "
  sql &= &" project_id = {rowData.project_id}"
  sql &= &",project_code = '{rowData.project_code}'"
  if rowData.day != DateTime():
    sql &= &",day = datetime('" & rowData.day.format("yyyy-MM-dd HH:mm:ss") & &"')"
  if rowData.from_time != DateTime():
    sql &= &",from_time = datetime('" & rowData.from_time.format("yyyy-MM-dd HH:mm:ss") & &"')"
  if rowData.to_time != DateTime():
    sql &= &",to_time = datetime('" & rowData.to_time.format("yyyy-MM-dd HH:mm:ss") & &"')"
  if rowData.updated_at != DateTime():
    sql &= &",updated_at = datetime('" & rowData.updated_at.format("yyyy-MM-dd HH:mm:ss") & &"')"

  sql &= &" where id = {rowData.primKey}"
  db.exec(sql.sql)
proc updateLogTable*(db: DbConn, rowDataSeq: seq[LogTable]) =
  for rowData in rowDataSeq:
    db.updateLogTable(rowData)
proc dumpLogTable*(db: DbConn, dirName = "csv") =
  dirName.createDir
  let
    fileName = dirName / "log.csv"
    f = fileName.open(fmWrite)
  f.writeLine("id,project_id,project_code,day,from_time,to_time,updated_at")
  for row in db.selectLogTable:
    f.write('"', $row.id, '"', ',')
    f.write('"', $row.project_id, '"', ',')
    f.write('"', $row.project_code, '"', ',')
    if row.day == DateTime():
      f.write(',')
    else:
      f.write(row.day.format("yyyy-MM-dd HH:mm:ss"), ',')
    if row.from_time == DateTime():
      f.write(',')
    else:
      f.write(row.from_time.format("yyyy-MM-dd HH:mm:ss"), ',')
    if row.to_time == DateTime():
      f.write(',')
    else:
      f.write(row.to_time.format("yyyy-MM-dd HH:mm:ss"), ',')
    if row.updated_at == DateTime():
      f.write(',')
    else:
      f.write(row.updated_at.format("yyyy-MM-dd HH:mm:ss"), ',')
    f.setFilePos(f.getFilePos - 1)
    f.writeLine("")
  f.close
proc insertCsvLogTable*(db: DbConn, fileName: string) =
  var parser: CsvParser
  defer: parser.close
  parser.open(fileName)
  parser.readHeaderRow
  while parser.readRow:
    var data: LogTable
    data.setDataLogTable("id", parser.rowEntry("id"))
    data.setDataLogTable("project_id", parser.rowEntry("project_id"))
    data.setDataLogTable("project_code", parser.rowEntry("project_code"))
    data.setDataLogTable("day", parser.rowEntry("day"))
    data.setDataLogTable("from_time", parser.rowEntry("from_time"))
    data.setDataLogTable("to_time", parser.rowEntry("to_time"))
    data.setDataLogTable("updated_at", parser.rowEntry("updated_at"))
    db.insertLogTable(data)
proc restoreLogTable*(db: DbConn, dirName = "csv") =
  let fileName = dirName / "log.csv"
  db.exec("delete from log".sql)
  db.insertCsvLogTable(fileName)
