#!/usr/bin/env bash
set -euo pipefail
package=com.diroka.neonycolmillos
adb install -r build/emulator.apk
adb logcat -c
adb shell monkey -p "$package" -c android.intent.category.LAUNCHER 1
sleep 8
adb shell pidof "$package"
adb shell input swipe 180 800 360 800 1200
adb shell input keyevent KEYCODE_HOME
sleep 1
adb shell monkey -p "$package" -c android.intent.category.LAUNCHER 1
sleep 2
adb shell pidof "$package"
adb shell am force-stop "$package"
adb shell monkey -p "$package" -c android.intent.category.LAUNCHER 1
sleep 3
adb shell pidof "$package"
adb exec-out screencap -p > build/android.png
adb logcat -d > build/android.log
if grep -E 'FATAL EXCEPTION|Fatal signal|SCRIPT ERROR|Parse Error' build/android.log; then exit 1; fi
echo 'Android API 29 x86_64: installation, launch, touch event, background, relaunch PASS' | tee build/android-result.txt
