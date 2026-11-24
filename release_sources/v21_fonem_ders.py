from pathlib import Path
import re
import shutil

# Only the recitation engine is vendored, not the upstream app/UI/fonts.
vendor = Path('release_sources/quran_library_upstream')
target = Path('lib/ders/fonem_motoru')
shutil.copytree(vendor / 'lib/src/tasmee/engine', target / 'engine', dirs_exist_ok=True)
services = target / 'core/services'
services.mkdir(parents=True, exist_ok=True)
shutil.copy2(vendor / 'lib/src/tasmee/core/services/tasmee_reference_store.dart', services)
shutil.copytree(vendor / 'assets/quran_lab', Path('assets/quran_lab'), dirs_exist_ok=True)
shutil.copy2(vendor / 'LICENSE', Path('assets/quran_lab/LICENSE-quran-library-MIT.txt'))
shutil.copy2(vendor / 'NOTICE', Path('assets/quran_lab/NOTICE-quran-library.txt'))
shutil.copy2('release_sources/v21_fonem_ders_ekrani.dart', 'lib/ders/fonem_ders_ekrani.dart')

p = Path('pubspec.yaml')
s = p.read_text(encoding='utf-8')
assert '  sherpa_onnx: ^1.13.4' in s
s = s.replace('  sherpa_onnx: ^1.13.4', '  sherpa_onnx: 1.13.8\n  get: ^4.7.2\n  dio: ^5.8.0\n  archive: ^4.0.0')
assert '    - assets/asr/tokens.txt' in s
s = s.replace('    - assets/asr/tokens.txt', '    - assets/asr/tokens.txt\n    - assets/quran_lab/')
p.write_text(s, encoding='utf-8')

p = Path('lib/main.dart')
s = p.read_text(encoding='utf-8')
assert s.count("import 'ders/ders_ekrani.dart';") == 1
s = s.replace("import 'ders/ders_ekrani.dart';", "import 'ders/fonem_ders_ekrani.dart';")
assert s.count('const DersEkrani()') >= 1
s = s.replace('const DersEkrani()', 'const FonemDersEkrani()')
p.write_text(s, encoding='utf-8')

# All model and reference assets are shipped with this APK. Never fetch speech
# models in the app or route microphone audio through the unused online engine.
print('V21: on-device phoneme engine and Turkish assessment screen installed.')
