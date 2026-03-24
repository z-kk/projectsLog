import
  std / [os, json],
  projectsLogpkg / [webserver, consts, dbtables]

proc makeConfFile() =
  ## 設定ファイルを作成
  let conf = %*{
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
    "holiday": [
      "9999-12-31",
    ],
    "restTime": [
      {
        "from": "12:00",
        "to": "13:00",
      },
    ],
  }
  ConfFile.writeFile(conf.pretty)

when isMainModule:
  if not ConfFile.fileExists or ConfFile.readFile == "":
    makeConfFile()
    echo "設定ファイル[conf.json]を記入してください"
    quit()
  createTables()
  startWebServer()
