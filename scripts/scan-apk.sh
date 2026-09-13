#!/bin/bash
# Usage: ./scan-apk.sh /path/to/apktool_output_folder

TARGET="${1:?Usage: ./scan-apk.sh <apktool_output_folder>}"
MANIFEST="$TARGET/AndroidManifest.xml"

echo "== Dangerous Permissions =="
grep -noP 'android:name="android\.permission\.(READ_SMS|SEND_SMS|RECEIVE_SMS|READ_CONTACTS|RECORD_AUDIO|CAMERA|ACCESS_FINE_LOCATION|ACCESS_COARSE_LOCATION|SYSTEM_ALERT_WINDOW|BIND_ACCESSIBILITY_SERVICE|REQUEST_INSTALL_PACKAGES|RECEIVE_BOOT_COMPLETED|BIND_DEVICE_ADMIN|WRITE_EXTERNAL_STORAGE|READ_PHONE_STATE|CALL_PHONE|PROCESS_OUTGOING_CALLS)"' "$MANIFEST" 2>/dev/null

echo "== Hardcoded IP:port =="
grep -rnoP '\b(?:\d{1,3}\.){3}\d{1,3}:\d{2,5}\b' "$TARGET"

echo "== Embedded URLs =="
grep -rnoP 'https?://[A-Za-z0-9.\-]+(:[0-9]+)?(/[^\s"'"'"'<>]*)?' "$TARGET"

echo "== C2 Panel-style Paths =="
grep -rnoP 'https?://[^\s"'"'"'<>]+/(gate|panel|bot|check-?in|c2|admin)\.php\b' "$TARGET"

echo "== Suspicious API Usage =="
grep -rnoP '(DexClassLoader|PathClassLoader|InMemoryDexClassLoader|Ljava/lang/reflect/Method|Runtime;->exec|ProcessBuilder|/system/bin/su|javax/crypto/Cipher|Base64;->decode)' "$TARGET"

echo "== Long Base64 Blobs =="
grep -rnoP '\b[A-Za-z0-9+/]{40,}={0,2}\b' "$TARGET"

echo "== Long Hex Blobs =="
grep -rnoP '\b(?:[0-9A-Fa-f]{2}){20,}\b' "$TARGET"
