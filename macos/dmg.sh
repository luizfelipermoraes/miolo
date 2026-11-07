#!/bin/sh
# Packs macos/build/Miolo.app into macos/build/Miolo.dmg: the usual window with the app on the
# left and a link to Applications on the right, to drag one onto the other.
# Run sh macos/build.sh first. The background comes from macos/dmg-background.html (see README).
set -e
cd "$(dirname "$0")/.."

APP=macos/build/Miolo.app
DMG=macos/build/Miolo.dmg
RW=macos/build/Miolo-rw.dmg
STAGE=macos/build/dmg
VOLUME=Miolo
[ -d "$APP" ] || { echo "Run sh macos/build.sh first"; exit 1; }

rm -rf "$STAGE" "$RW" "$DMG"
mkdir -p "$STAGE/.background"
cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"
cp macos/dmg-background.tiff "$STAGE/.background/background.tiff"

# a volume already mounted under the same name would take the window settings instead
hdiutil detach "/Volumes/$VOLUME" -quiet 2>/dev/null || true
hdiutil create -srcfolder "$STAGE" -volname "$VOLUME" -fs HFS+ -format UDRW -ov "$RW" -quiet
DEVICE=$(hdiutil attach -readwrite -noverify -noautoopen "$RW" | awk '/Apple_HFS/ {print $1}')

# Finder keeps the window layout in the volume's .DS_Store
osascript <<EOF
tell application "Finder"
  tell disk "$VOLUME"
    open
    set current view of container window to icon view
    set toolbar visible of container window to false
    set statusbar visible of container window to false
    set the bounds of container window to {200, 120, 840, 548}
    set opts to the icon view options of container window
    set arrangement of opts to not arranged
    set icon size of opts to 112
    set text size of opts to 13
    set background picture of opts to file ".background:background.tiff"
    set position of item "Miolo.app" of container window to {170, 236}
    set extension hidden of item "Miolo.app" to true
    set position of item "Applications" of container window to {470, 236}
    update without registering applications
    delay 1
    close
  end tell
end tell
EOF

sync
hdiutil detach "$DEVICE" -quiet
hdiutil convert "$RW" -format UDZO -imagekey zlib-level=9 -o "$DMG" -quiet
rm -rf "$STAGE" "$RW"
echo "Built $DMG ($(du -sh "$DMG" | cut -f1))"
