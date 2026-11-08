"""Configure SDKs explicitly in Godot's editor settings."""
import json
import os
import re
from pathlib import Path
settings = Path.home() / '.config/godot/editor_settings-4.3.tres'
text = settings.read_text() if settings.exists() else '[gd_resource type="EditorSettings" format=3]\n\n[resource]\n'
values = {
    'export/android/android_sdk_path': os.environ['ANDROID_HOME'],
    'export/android/java_sdk_path': os.environ['JAVA_HOME'],
    'export/android/debug_keystore': os.environ['RUNNER_TEMP'] + '/debug.keystore',
    'export/android/debug_keystore_user': 'androiddebugkey',
    'export/android/debug_keystore_pass': 'android',
}
for key, value in values.items():
    text = re.sub(r'^' + re.escape(key) + r' = .*\n?', '', text, flags=re.MULTILINE)
    text += key + ' = ' + json.dumps(value) + '\n'
settings.parent.mkdir(parents=True, exist_ok=True)
settings.write_text(text)
