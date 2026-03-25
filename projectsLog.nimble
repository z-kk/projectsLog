# Package

version       = "0.5.0"
author        = "z-kk"
description   = "Make Projects log data"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["projectsLog"]
binDir        = "bin"


# Dependencies

requires "nim >= 2.0.0"
requires "db_connector"
requires "neel"
requires "htmlgenerator"


# Tasks

task r, "build and run":
  exec "nimble build"
  exec "nimble ex"

import os
task ex, "run without build":
  withDir binDir:
    exec "if [ ! -e assets ]; then ln -s ../src/static assets; fi"
    exec "." / bin[0]
