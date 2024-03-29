const
  ConfFile* = "config.json"
  DateFormat* = "yyyy-MM-dd"
  DateTimeFormat* = "yyyy-MM-dd HH:mm"

  GanttFile* = "gantt.mmd"

type
  tablePref* = enum
    proj, cat, content, `from`, to

proc projStr*(i: int): string =
  "proj_" & $i

proc catStr*(i: int): string =
  "cat_" & $i

proc contentStr*(i: int): string =
  "content_" & $i

proc fromStr*(i: int): string =
  "from_" & $i

proc toStr*(i: int): string =
  "to_" & $i
