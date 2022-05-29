import
  jester,
  makeHtml

router rt:
  get "/":
    resp makeMainPage()

proc startHttpServer*(port = 0) =
  var jest =
    if port < 1:
      rt.initJester
    else:
      let settings = newSettings(Port(port))
      rt.initJester(settings)
  jest.serve
