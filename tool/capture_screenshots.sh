#!/usr/bin/env bash
# Chụp màn hình MVP (sáng/tối, vi/en, chữ 2x) vào docs/screenshots/mvp/.
# Cách dùng: bash tool/capture_screenshots.sh [device-id]   (mặc định: emulator-5554)
# integration_test/screenshots_test.dart in mốc "VX_SHOT <tên>" rồi đứng yên 4 giây;
# script này theo dõi log và chụp bằng adb khi thấy mốc mới.
set -euo pipefail
DEVICE="${1:-emulator-5554}"
ADB="${ADB:-adb}"
OUT="docs/screenshots/mvp"
LOG="$(mktemp)"
mkdir -p "$OUT"

(flutter test integration_test/screenshots_test.dart -d "$DEVICE" > "$LOG" 2>&1; echo "VX_END $?" >> "$LOG") &

taken=" "
while ! grep -q "VX_END" "$LOG"; do
  for name in $(grep -o "VX_SHOT [a-z0-9-]*" "$LOG" | awk '{print $2}'); do
    case "$taken" in
      *" $name "*) ;;
      *)
        sleep 1.5
        "$ADB" -s "$DEVICE" exec-out screencap -p > "$OUT/$name.png"
        taken="$taken$name "
        echo "đã chụp $name"
        ;;
    esac
  done
  sleep 0.5
done
wait
grep "VX_END" "$LOG"
