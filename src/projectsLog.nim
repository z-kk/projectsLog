import
  os, json,
  projectsLogpkg / [httpServer, consts, dbtables]

proc getPort(): int =
  ## サーバを起動するポートを取得
  let conf = ConfFile.parseFile
  if "port" in conf:
    return conf["port"].getInt

proc makeConfFile() =
  ## 設定ファイルを作成
  let conf = %*{
    "port": 5000,
    "projects": {
      "projectName1": {
        "id": 1,
        "code": "projectCode",
      },
      "projectName2": {
        "id": 2,
        "code": "projectCode",
      },
    },
  }
  ConfFile.writeFile(conf.pretty)
  echo "設定ファイル[conf.json]を記入してください"

when isMainModule:
  if not ConfFile.fileExists:
    makeConfFile()
    quit()
  openDb().createTables
  let port = getPort()
  startHttpServer(port)
