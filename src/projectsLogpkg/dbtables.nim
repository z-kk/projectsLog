import
  db_sqlite,
  std / os,
  csvDir / [log]
export
  db_sqlite,
  log
proc getDbFileName*(): string =
  let dir = "."
  return dir / "log.db"
proc openDb*(): DbConn =
  let db = open(getDbFileName(), "", "", "")
  return db
proc createTables*() =
  getDbFileName().parentDir.createDir
  let db = openDb()
  db.createLogTable
  db.close
