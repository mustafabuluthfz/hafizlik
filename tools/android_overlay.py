#!/usr/bin/env python3
"""flutter create ile üretilen Android projesine namaz vakitleri widget'ını ekler."""
import re
import shutil
from pathlib import Path

ana = Path('android/app/src/main')
ov = Path('android_overlay')

main_activity = next(ana.rglob('MainActivity.kt'), None)
if main_activity is None:
    raise SystemExit('MainActivity.kt bulunamadı')
paket = re.search(r'^package\s+([\w.]+)', main_activity.read_text(encoding='utf-8'), re.M).group(1)

kt = (ov / 'kotlin/VakitWidgetProvider.kt').read_text(encoding='utf-8').replace('__PACKAGE__', paket)
(main_activity.parent / 'VakitWidgetProvider.kt').write_text(kt, encoding='utf-8')

for alt in ['layout/vakit_widget.xml', 'xml/vakit_widget_info.xml']:
    hedef = ana / 'res' / alt
    hedef.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy(ov / 'res' / alt, hedef)

manifest = ana / 'AndroidManifest.xml'
metin = manifest.read_text(encoding='utf-8')
if 'VakitWidgetProvider' not in metin:
    receiver = (
        '        <receiver android:name=".VakitWidgetProvider" android:exported="false" '
        'android:label="Namaz Vakitleri">\n'
        '            <intent-filter>\n'
        '                <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />\n'
        '            </intent-filter>\n'
        '            <meta-data android:name="android.appwidget.provider" '
        'android:resource="@xml/vakit_widget_info" />\n'
        '        </receiver>\n    '
    )
    metin = metin.replace('</application>', receiver + '</application>', 1)
    manifest.write_text(metin, encoding='utf-8')

print('Android widget dosyaları eklendi, paket:', paket)
