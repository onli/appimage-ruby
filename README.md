# appimage-ruby
Transform a ruby program into an appimage.

## Installation

Clone this repo. Make sure that `appimagetool` is available (you can download it as appimage from [https://github.com/AppImage/AppImageKit/releases](https://github.com/AppImage/AppImageKit/releases) and put it into your `PATH`).

## Usage

To appimagify your ruby project, run `build_appimage.sh`:

    ./build_appimage.sh --appdir appdir --sourcedir exampleapp

The goal is to automatically install the needed gems (as specified in the Gemfile), find the ruby entry point (e.g. config.ru) and let the appimage run that. That detection is not implemented yet.

## Concept

The `build_appimage.sh` first creates an AppDir with a ruby installation and its dependencies. It adds some scripts to run ruby projects, installs its dependencies (TODO) and then calls `appimagetool` to create an AppImage out of the AppDir.

### In more detail

Currently, [portable ruby](https://portableruby.com/) is used and provides Ruby 2.6.3, but that might be changed later. That installation is patched slightly so that it works in the modified path structure.

Next step is installing bundler, to be able to install ruby gems projects need.

The target ruby project code is copied to **opt/**.

When starting the appimage, a wrapper script **usr/bin/rubyapp** is run. Its job is to prepare everything needed to make the supplied ruby work (so far: call `ruby_environment`) and then to identify and run the starting point of the target ruby program.

## ToDo

- [ ] Make **usr/bin/rubyapp** smart enough to identify ruby program entry points
- [ ] Add a way to supply a custom start command
- [ ] Run `bundle install` to install dependencies of the target program on image creation
- [ ] Add a way to provide needed system dependencies (e.g. sqlite3-dev)
- [ ] Extract the useful parts of this as linuxdeploy plugin/transform this into one or multiple linuxdeploy plugins
- [ ] Make use of https://github.com/AppImageCrafters/appimage-builder to handle system dependencies (and replace portable ruby?)
