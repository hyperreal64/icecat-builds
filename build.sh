#!/usr/bin/env sh

set -o errexit
set -x

GNUZILLA_GIT="git.savannah.gnu.org/git/gnuzilla.git"
ROOT_DIR="${PWD}"
BUILD_DIR="${ROOT_DIR}/build"
INSTALL_PREFIX="${ROOT_DIR}/icecat/usr"
DEBIAN_DIR="${ROOT_DIR}/icecat/debian"
ICECAT_VERSION="115.20.0"

# Install build dependencies
sudo apt install git gpg mercurial rename python3-jsonschema clang pkg-config libasound2-dev libpulse-dev curl cbindgen nodejs libpango1.0-dev unzip libxtst-dev libxdamage-dev libxcursor-dev libxcomposite-dev libxrandr-dev libx11-dev libxcb1-dev libx11-xcb-dev nasm libgtk-3-dev libdbus-glib-1-dev make m4

# Clone Icecat sources
mkdir "$BUILD_DIR"
git clone "https://${GNUZILLA_GIT}" "${BUILD_DIR}/gnuzilla"

# Run makeicecat
cd "${BUILD_DIR}/gnuzilla"
./makeicecat

# Run configure script
cd "output/icecat-${ICECAT_VERSION}"
mkdir obj
cd obj
../configure --without-wasm-sandboxed-libraries --prefix="$INSTALL_PREFIX"

# Run make to build Icecat (will take a while)
make

# Run make install
make install

# Remove executable bit from shared libraries
find "${INSTALL_PREFIX}/lib/icecat" -name "*.so" -exec chmod 644 {} \;

# Create symlinks to icecat.png
for size in "16x16" "32x32" "48x48" "64x64" "128x128"; do mkdir -p "${INSTALL_PREFIX}/share/icons/hicolor/${size}/apps"; done
ln -sf "${INSTALL_PREFIX}/lib/icecat/browser/chrome/icons/default/default16.png" "${INSTALL_PREFIX}/share/icons/hicolor/16x16/apps/icecat.png"
ln -sf "${INSTALL_PREFIX}/lib/icecat/browser/chrome/icons/default/default32.png" "${INSTALL_PREFIX}/share/icons/hicolor/32x32/apps/icecat.png"
ln -sf "${INSTALL_PREFIX}/lib/icecat/browser/chrome/icons/default/default48.png" "${INSTALL_PREFIX}/share/icons/hicolor/48x48/apps/icecat.png"
ln -sf "${INSTALL_PREFIX}/lib/icecat/browser/chrome/icons/default/default64.png" "${INSTALL_PREFIX}/share/icons/hicolor/64x64/apps/icecat.png"
ln -sf "${INSTALL_PREFIX}/lib/icecat/browser/chrome/icons/default/default128.png" "${INSTALL_PREFIX}/share/icons/hicolor/128x128/apps/icecat.png"

# Copy icecat.desktop
mkdir -p "${INSTALL_PREFIX}/share/applications"
cp -v "${ROOT_DIR}/icecat.desktop" "${INSTALL_PREFIX}/share/applications/icecat.desktop"

# Update changelog
cd "$DEBIAN_DIR"

CHANGELOG_DATE=$(date -u +"%a, %d %b %Y %H:%M:%S %z")

cat >>changelog-head <<EOF
icecat ($ICECAT_VERSION-1) unstable; urgency=medium

  * Update to $ICECAT_VERSION.

 -- hyperreal <hyperreal@moonshadow.dev> $CHANGELOG_DATE
EOF

cp -fv changelog changelog-tail
cat changelog-head changelog-tail >changelog
rm -fv changelog-head changelog-tail
cp -fv changelog "${INSTALL_PREFIX}/share/doc/icecat/"
gzip --best -n "${INSTALL_PREFIX}/usr/share/doc/icecat/changelog"
cp -fv copyright "${INSTALL_PREFIX}/share/doc/icecat/"

# Build Debian package
cd "$ROOT_DIR"
mv icecat "icecat-${ICECAT_VERSION}-1_amd64"

## TODO: Maybe a better way to build the package, e.g., with like debuild or something?
dpkg-deb --root-owner-group --build "icecat-${ICECAT_VERSION}-1_amd64"
