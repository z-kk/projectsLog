import
  std / [times, json],
  consts

type
  projInfo* = object
    name*: string
    category*: string
    content*: string
    fromTime*: DateTime
    toTime*: DateTime

proc updateLog*(infoList: seq[projInfo]): JsonNode =
  ## ログデータを登録
  for info in infoList:
    try:
      echo info.name
      echo info.category
      echo info.content
      echo info.fromTime.format(DateTimeFormat)
      echo info.toTime.format(DateTimeFormat)
    except:
      return %*{ "result": false, "exception": getCurrentExceptionMsg() }

  return %*{ "result": true }
