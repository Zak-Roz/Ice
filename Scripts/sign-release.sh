#!/bin/bash
#
# Re-signs a built Ice.app for release, inside out, with the hardened runtime on
# every piece of nested code.
#
#   Scripts/sign-release.sh <path/to/Ice.app> <identity> [keychain]
#
# <identity> is a code signing identity (its SHA-1 hash or name), or "-" for an
# ad-hoc signature when testing the script locally.
#
# Why not `codesign --deep`: it signs nested code in no particular order and,
# without `--options runtime`, drops the hardened runtime, which lets any local
# process inject code into Ice with DYLD_INSERT_LIBRARIES and use the
# Accessibility and Screen Recording access the user granted it.

set -euo pipefail

APP="${1:?usage: sign-release.sh <Ice.app> <identity> [keychain]}"
IDENTITY="${2:?usage: sign-release.sh <Ice.app> <identity> [keychain]}"
KEYCHAIN="${3:-}"

SIGN=(codesign --force --options runtime --timestamp=none --sign "$IDENTITY")
if [ -n "$KEYCHAIN" ]; then
    SIGN+=(--keychain "$KEYCHAIN")
fi

SPARKLE="$APP/Contents/Frameworks/Sparkle.framework"
if [ -d "$SPARKLE" ]; then
    # Order and flags follow Sparkle's documentation for re-signing the framework.
    "${SIGN[@]}" "$SPARKLE/Versions/B/XPCServices/Installer.xpc"
    "${SIGN[@]}" --preserve-metadata=entitlements "$SPARKLE/Versions/B/XPCServices/Downloader.xpc"
    "${SIGN[@]}" "$SPARKLE/Versions/B/Autoupdate"
    "${SIGN[@]}" "$SPARKLE/Versions/B/Updater.app"
    "${SIGN[@]}" "$SPARKLE"
fi

for SERVICE in "$APP"/Contents/XPCServices/*.xpc; do
    [ -e "$SERVICE" ] || continue
    "${SIGN[@]}" --preserve-metadata=entitlements "$SERVICE"
done

"${SIGN[@]}" --preserve-metadata=entitlements "$APP"

codesign --verify --deep --strict --verbose=2 "$APP"

# Every piece of code must carry the hardened runtime, and nothing may keep
# get-task-allow (which Xcode adds to "Sign to Run Locally" builds).
FAILED=0
while IFS= read -r -d '' CODE; do
    INFO=$(codesign -dvv "$CODE" 2>&1 || true)
    if ! grep -q 'flags=.*runtime' <<< "$INFO"; then
        echo "error: no hardened runtime on $CODE" >&2
        FAILED=1
    fi
    if codesign -d --entitlements :- "$CODE" 2>/dev/null | grep -q 'get-task-allow'; then
        echo "error: get-task-allow entitlement on $CODE" >&2
        FAILED=1
    fi
done < <(find "$APP" \( -name '*.app' -o -name '*.xpc' -o -name '*.framework' -o -name 'Autoupdate' \) -print0)

# A certificate without an Apple Team ID (self-signed) fails library validation
# for every embedded framework, and dyld kills the app at launch with "different
# Team IDs". Such an app must opt out of library validation.
EXECUTABLE="$APP/Contents/MacOS/$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$APP/Contents/Info.plist")"
APP_INFO=$(codesign -dvv "$APP" 2>&1 || true)
if ! grep -q 'Signature=adhoc' <<< "$APP_INFO" \
    && grep -q 'TeamIdentifier=not set' <<< "$APP_INFO" \
    && otool -L "$EXECUTABLE" | grep -q '@rpath/' \
    && ! codesign -d --entitlements :- "$APP" 2>/dev/null | grep -q 'com.apple.security.cs.disable-library-validation'; then
    echo "error: $APP has no Team ID and loads embedded frameworks, but library validation is on: it would crash at launch" >&2
    FAILED=1
fi
exit "$FAILED"
