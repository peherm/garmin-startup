#!/bin/bash

# This script updates the version in manifest.xml and SailStartupApp.mc
# based on the git tag provided as the first argument.

if [ -z "$1" ]; then
  echo "Error: No version provided. Usage: ./update_version.sh 0.2.0"
  exit 1
fi

VERSION=$1

# 1. Update manifest.xml
# Replaces version="x.x.x" with version="VERSION"
sed -i "s/version=\"[0-9.]*\"/version=\"$VERSION\"/g" SailStartup/manifest.xml

# 2. Update SailStartupApp.mc
# Replaces VERSION = "x.x.x" with VERSION = "VERSION"
sed -i "s/VERSION = \"[0-9.]*\"/VERSION = \"$VERSION\"/g" SailStartup/source/SailStartupApp.mc

echo "Version updated to $VERSION in manifest.xml and SailStartupApp.mc"
