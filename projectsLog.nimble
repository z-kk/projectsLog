# Package

version       = "0.3.0"
author        = "z-kk"
description   = "Make Projects log data"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["projectsLog"]
binDir        = "bin"


# Dependencies

requires "nim >= 1.6.0"
requires "jester"
requires "htmlgenerator"


# Tasks

task r, "build and run":
  exec "nimble build"
  exec "nimble ex"

import os
task ex, "run without build":
  withDir binDir:
    exec "if [ ! -e public ]; then ln -s ../src/html public; fi"
    for b in bin:
      exec "." / b
