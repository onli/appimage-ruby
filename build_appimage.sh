#! /bin/bash

# abort on all errors
set -e

if [ "$DEBUG" != "" ]; then
    set -x
fi

script=$(readlink -f "$0")

show_usage() {
    echo "Usage: $script --appdir <path to AppDir> --sourcedir <path to Ruby code>"
    echo
    echo "Bundles ruby into the AppDir."
    echo
    echo "  ARCH=\"x86_64\" (further supported values: i686)"
}

APPDIR=

while [ "$1" != "" ]; do
    case "$1" in
        --plugin-api-version)
            echo "0"
            exit 0
            ;;
        --appdir)
            APPDIR="$2"
            shift
            shift
            ;;
        --sourcedir)
            SOURCEDIR="$2"
            shift
            shift
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            echo "Invalid argument: $1"
            echo
            show_usage
            exit 1
            ;;
    esac
done

if [ "$APPDIR" == "" ]; then
    show_usage
    exit 1
fi

mkdir -p "$APPDIR"


# create temporary directory into which downloaded files are put
TMPDIR=$(mktemp -d)

_cleanup() {
    rm -rf "$TMPDIR"
}

trap _cleanup EXIT

if [ -d "$APPDIR"/usr/portableruby ]; then
    echo "Error: directory exists: $APPDIR/usr/portableruby"
    exit 1
fi

ARCH=${ARCH:-x86_64}

# install Miniconda, a self contained Python distribution, into AppDir
case "$ARCH" in
    "x86_64")
        portableruby_url=https://portableruby.s3.amazonaws.com/ruby-2.6.3.tar.gz
        ;;
    *)
        echo "Error: Unknown portable ruby arch: $ARCH"
        exit 1
        ;;
esac

(cd "$TMPDIR" && wget "$portableruby_url")

# install into usr/portableruby/ instead of usr/ to make sure that the libraries shipped with portableruby don't overwrite or
# interfere with libraries bundled by other plugins or linuxdeploy itself
mkdir -p "$APPDIR"/usr/portableruby
tar xzf "$TMPDIR"/ruby-*.tar.gz -C "$APPDIR"/usr/portableruby

# activate environment
"$APPDIR"/usr/portableruby/bin/ruby_environment

# we don't want to touch the system, therefore using a temporary home
mkdir _temp_home
export HOME=$(readlink -f _temp_home)

# Install bundler, so we can install gems
"$APPDIR"/usr/portableruby/bin/gem install bundler --no-document


# create symlinks for all binaries in usr/portableruby/bin/ in usr/bin/
mkdir -p "$APPDIR"/usr/bin/
pushd "$APPDIR"
for i in usr/portableruby/bin/*; do
    ln -s ../../"$i" usr/bin/
done
# help the protable ruby wrapper to find its files
ln -s portableruby/bin.real usr/bin.real
popd

# patch ruby_environment with ROOT="$ROOT/portableruby" so it can find the gems
sed -i '3 a ROOT="$ROOT/portableruby"' $APPDIR/usr/portableruby/bin/ruby_environment

# place target files under opt

mkdir "$APPDIR"/opt/
for i in "$SOURCEDIR"/*; do
    cp -R "$i" "$APPDIR"/opt/
done

# create a wrapper script usr/bin/rubyapp that loads ruby_environment and starts app under opt/
# TODO: Start something generic like config.ru, not hello_world.rb
cat > "$APPDIR"/usr/bin/rubyapp  <<\EOF
#!/bin/sh
ruby_environment
ROOT=`dirname "$0"`
ROOT=`cd "$ROOT/.." &>/dev/null && pwd`
ruby "$ROOT/../opt/hello_world.rb"
EOF
chmod +x "$APPDIR"/usr/bin/rubyapp

# create the .desktop file to start that wrapper
cat > "$APPDIR"/rubyapp.desktop <<\EOF
[Desktop Entry]
X-AppImage-Arch=x86_64
X-AppImage-Version=0.1
X-AppImage-Name=rubyapp
Name=rubyapp
Exec=rubyapp
Icon=ruby
Type=Application
Terminal=true
Categories=Utility;
Comment=
EOF

wget "https://www.ruby-lang.org/images/header-ruby-logo.png" -O "$APPDIR"/ruby.png

# Add AppRun for now
wget "https://github.com/AppImage/AppImageKit/releases/download/continuous/AppRun-x86_64" -O "$APPDIR"/AppRun
chmod +x "$APPDIR"/AppRun

appimagetool $APPDIR


