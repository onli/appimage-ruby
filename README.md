# appimage-ruby
Transform a ruby program into an appimage.

## Installation

Clone this repo. Make sure that `appimagetool` is available (you can download it as appimage from [https://github.com/AppImage/AppImageKit/releases](https://github.com/AppImage/AppImageKit/releases) and put it into your `PATH`).

## Usage

To appimagify your ruby project, run `build_appimage.sh`:

    ./build_appimage.sh --appdir appdir --sourcedir exampleapp

The goal is to automatically install the needed gems (as specified in the Gemfile), find the ruby entry point (e.g. config.ru) and let the appimage run that. That detection is not implemented yet.