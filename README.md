# blam

![GPLv3](https://img.shields.io/github/license/Sodaware/blam.svg)
![GitHub release](https://img.shields.io/github/release/Sodaware/blam.svg)

`blam` is a very simple build system for Blitz. It's based on BlitzBuild, but
has been rebuilt in BlitzMax and made cross-platform.


## Quick Links

Project Homepage:
: https://www.sodaware.net/blam/

Source Code
: https://github.com/sodaware/blam/

Full Documentation
: https://docs.sodaware.net/blam/latest/


## Overview

`blam` looks to a file called either `blam.xml` or `build.xml` in the current
working directory. This file must contain a `project` node as the root and at
least one `target` element.

A simple build file looks something like this:

```xml
<?xml version="1.0"?>
<project name="example" default="build:debug">

  <!-- Build properties -->
  <property name="build.paths.base"   value="${project::get-buildfile-path()}" />
  <property name="build.paths.source" value="${build.paths.base}/src" />
  <property name="build.paths.output" value="${build.paths.base}/build" />

  <!-- Building -->
  <target name="build:debug" description="Build the app in debug mode">
    <bmk action="makeapp" threaded="true" gui="false"
         output="${build.paths.output}/example"
         source="${build.paths.source}/app.bmx" />
  </target>

</project>
```

The build file can then be run by calling `blam build:debug` (or just `blam`
when executing the default target).


## Configuration

Before `blam` can properly run, it needs to be configured with paths to
BlitzMax. `blam` will autoload the contents of `blam.ini` or `blitzbuild.ini` in
the `blam` executable's directory.

The ini should contain the following information:

```ini
# Configuration file for blam
[BlitzMax]
win32       = c:\path\to\blitzmax\bin\bmk.exe
linux		= /path/to/blitzmax/bin/bmk
macos		= /path/to/blitzmax/bin/bmk
```

`blam` will complain if the `bmk` executable is not found, but it can still be
used to run non-bmk tasks.


## Usage

Calling `blam` with the name of a target will execute that target in the
default build file.

Some of the most commonly-used alternative commands are:

  - `-f` or `--file-name` -- Specify the build file to execute (instead of the
    default `blam.xml`/`build.xml`.
  - `-t` or `--target` -- Specify the build target to call. Alternatively
    specify the build target as the last argument.
  - `-l` or `--list` -- List all build targets in the build file.

For example, `blam -f=myfile.xml -t=mytarget` will run `mytarget` in the
`myfile.xml` file (if both exist).

`blam --help` lists all available commands and switches.


## Building

### Prerequisites

  - BlitzMax
  - Modules required (not including built-in brl.mod and pub.mod):
    - [sodaware.mod](https://github.com/sodaware/sodaware.mod)
      - sodaware.console\_basic
      - sodaware.console\_color
      - sodaware.console\_commandline
      - sodaware.file\_config
      - sodaware.file\_config\_iniserializer
      - sodaware.file\_fnmatch
      - sodaware.file\_ini
      - sodaware.file\_util
      - sodaware.file\_ziphelper
      - sodaware.stringtable
    - [prime.mod](https://github.com/kfprimm/prime.mod)
      - prime.maxml
    - [bah.mod](https://github.com/maxmods/bah.mod)
      - bah.volumes
    - [gman.mod](https://github.com/maxmods/gman.mod)
      - gman.zipengine

### Compiling

To build the app in release mode, run the following from the command line:

```
bmk makeapp -h -r -o build/blam src/main.bmx
```

Copy the `blam` executable to its final destination.


## Licence

Released under the GPLv3. See `COPYING` for the full licence.
