import
  db_sqlite,
  csvDir / [log]
export
  db_sqlite,
  log
proc openDb*(): DbConn =
  let db = open("log.db", "", "", "")
  return db
proc createTables*(db: DbConn) =
  db.createLogTable
