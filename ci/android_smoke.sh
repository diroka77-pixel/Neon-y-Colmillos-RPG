#!/usr/bin/env bash
set -euo pipefail
package=com.diroka.neonycolmillos
# Disable Android's first-use overlay so it cannot swallow the gameplay touches.
adb shell settings put secure immersive_mode_confirmations confirmed
adb install -r build/emulator.apk
adb logcat -c
launch() {
  adb shell monkey -p "$package" -c android.intent.category.LAUNCHER 1
}
wait_ready() {
  for attempt in $(seq 1 30); do
    adb logcat -d -s godot > build/android-current.log
    if grep -q NEON_READY build/android-current.log; then return 0; fi
    sleep 1
  done
  cat build/android-current.log
  return 1
}
launch
wait_ready
sleep 3
adb shell pidof "$package"
# Pixel 2 emulator runs landscape 1920x1080: viewport is 960x540.
adb shell input tap 1736 894
sleep 1
adb logcat -d -s godot > build/android-current.log
grep 'NEON_TERMINAL 1' build/android-current.log
adb shell input swipe 220 870 350 870 1200
sleep 1
adb logcat -d -s godot > build/android-current.log
grep NEON_MOVED build/android-current.log
adb shell input keyevent KEYCODE_HOME
sleep 1
launch
sleep 3
adb shell pidof "$package"
adb shell am force-stop "$package"
adb logcat -c
launch
wait_ready
sleep 4
adb shell pidof "$package"
adb exec-out screencap -p > build/android.png
adb logcat -d > build/android.log
if grep -E 'FATAL EXCEPTION|Fatal signal|SCRIPT ERROR|Parse Error|E godot.*(ERROR|shader failed)' build/android.log; then exit 1; fi
echo 'Android API 29 x86_64: scene ready, terminal touch, movement touch, background and cold relaunch PASS' | tee build/android-result.txt
