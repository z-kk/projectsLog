import
  os, json,
  projectsLogpkg / [httpServer, consts]

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
    "categories": [
      "実装", "評価", "書類", "会議", "検討", "その他"
    ],
  }
  ConfFile.writeFile(conf.pretty)
  echo "設定ファイル[conf.json]を記入してください"

when isMainModule:
  if not ConfFile.fileExists:
    makeConfFile()
    quit()
  let port = getPort()
  startHttpServer(port)
