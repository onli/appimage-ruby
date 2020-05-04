# appimage-ruby
Transform a ruby program into an appimage.

## Installation

Clone this repo. Make sure that `appimagetool` is available (you can download it as appimage from [https://github.com/AppImage/AppImageKit/releases](https://github.com/AppImage/AppImageKit/releases) and put it into your `PATH`).

## Usage

To appimagify your ruby project, run `build_appimage.sh`:

    ./build_appimage.sh --appdir appdir --sourcedir exampleapp

The goal is to automatically install the needed gems (as specified in the Gemfile), find the ruby entry point (e.g. config.ru) and let the appimage run that. That detection is not implemented yet.

## Concept

The build_script creates an AppDir with a ruby installation and its dependencies. Currently, that's [portable ruby](https://portableruby.com/) and provides Ruby 2.6.3, but that might be changed later. That installation is patched slightly so that the appimage can use it.

Next step is installing bundler, to be able to install ruby gems projects need.

The project code is copied to **opt/**.

When starting the appimage, a wrapper script **usr/bin/rubyapp** is run. It is a wrapper script. Its job is to prepare everything needed to make the supplied ruby work (so far: call `ruby_environment`) and then to identify the starting point of the target ruby program.

## ToDo

 1. Make **usr/bin/rubyapp** smart enough to identify ruby program entry points
 1. Add a way to supply a custom start command
 1. Run `bundle install` to install dependencies of the target program on image creation
 1. Add a way to provide needed system dependencies (e.g. sqlite3-dev)
 1. Extract the useful parts of this as linuxdeploy plugin/transform this into one or multiple linuxdeploy plugins