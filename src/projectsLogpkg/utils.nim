import
  std / [json, net, httpclient],
  jester, htmlgenerator,
  consts

type
  BasePageParams* = object
    title*: string
    lnk*: seq[string]
    header*: seq[string]
    sidemenu*: seq[string]
    body*: seq[string]
    footer*: seq[string]
    script*: seq[string]
    appName*: string

proc uri*(request: Request, address = ""): string =
  ## Create a URI without `request.host` and `request.port`
  uri(address, false)

proc newParams*(req: Request): BasePageParams =
  result.appName = req.appName

proc newLink*(req: Request, path = ""): hlink =
  newLink(req.uri(path))

proc newScript*(req: Request, path = ""): hscript =
  newScript(req.uri(path))

proc getHoliday*(): seq[string] =
  ## Get Japanese holiday and holiday in config.json
  var client = newHttpClient(sslContext=newContext(verifyMode=CVerifyPeer))
  try:
    let j = client.getContent("https://holidays-jp.github.io/api/v1/date.json").parseJson
    for key, _ in j:
      result.add key
  finally:
    client.close
  let conf = ConfFile.readFile.parseJson
  for h in conf["holiday"]:
    result.add h.getStr
