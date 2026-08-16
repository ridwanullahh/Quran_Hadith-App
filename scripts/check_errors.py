import os, re, sys


def check_directory(dart_dir):
    errors = []
    for root, dirs, files in os.walk(dart_dir):
        for f in files:
            if not f.endswith('.dart'):
                continue
            try:
                with open(f, 'r') as fh:
                    content = fh.read()
                except Exception as e:
                    errors.append(f'{f}: READ ERROR: {e}')
                    continue
            
            # Check for potential compilation issues
            # that aren't caught by static analysis
            try:
                content = fh.read()
            except Exception:
                continue

            # 1. Check for broken imports (package: that doesn't exist in pubspec)
            for match in re.finditer(r"import 'package:(?!flutter/)([^';]+)'', content):
                pkg = match.group(1)
                # Skip flutter SDK and known valid packages
                known = {'flutter', 'cupertino_icons', 'flutter_riverpod', 'go_router', 'sqflite', 'hive', 'hive_flutter', 
                         'just_audio', 'audio_service', 'audio_session', 'dio', 'flutter_animate', 
                         'google_fonts', 'fl_chart', 'percent_indicator', 'fl_chart', 'intl', 
                         'uuid', 'share_plus', 'file_picker', 'json_annotation', 
                         'rxdart', 'arabic_numbers', 'flutter_markdown', 
                         'flutter_service', 'path', 'path_provider'}
                if pkg not in known:
                    errors.append(f'{f}:{pkg}: unknown package import')

            # 2. Check for @riverpod, @freezed, @jsonSerializable annotations
            for match in re.finditer(r'@\w+(riverpod|freezed|JsonSerializable|JsonKey|DriftDatabase|DriftTable)', content):
                errors.append(f'{f}:{match.group(0)}: code gen annotation found: {match.group(0)}')

            # 3. Check for part directives
            if 'part' in content and '.g.dart' in content:
                errors.append(f'{f}: part directive found')

            # 4. Check for Color.withValues
            if 'withValues' in content:
                errors.append(f'{f}: withValues found (Flutter 3.27+ API)')

            # 5. Check for undefined types mentioned
            for match in re.finditer(r"(?:Undefined name|isn't defined|The method|The getter|isn't a type)", content):
                # Filter out common false positives
                if 'ColumnType' not in match and 'BuildContext' not in match:
                    errors.append(f'{f}:{match.group(0)[:80]}')

            # 6. Check for specific known issues
            if 'RepeatMode.' in content and 'import.*audio_service' not in content:
                errors.append(f'{f}: RepeatMode without audio_service import')
            if 'ShakeEffect.h' in content:
                errors.append(f'{f}: ShakeEffect.h found')
            if 'AudioProcessingState.error' in content and 'case AudioProcessingState.error:' not in content:
                errors.append(f'{f}: unhandled AudioProcessingState.error')
            if 'Hive.' in content and 'import.*hive' not in content:
                errors.append(f'{f}: Hive used without import')
            if 'AudioService.init(' in content and 'create:' not in content and 'builder:' not in content:
                errors.append(f'{f}: AudioService.init(create:) API mismatch')
            if 'StateNotifierProvider' in content and 'StateNotifier<' not in content:
                # False positive, common pattern
                pass
            if 'ShakeEffect(' in content and 'horizontal:' not in content:
                errors.append(f'{f}: ShakeEffect.h parameter issue')
            if 'state = const' in content:
                errors.append(f'{f}: const with non-const value')
            if 'Hive.box(' in content and 'hive_flutter' not in content:
                errors.append(f'{f}: Hive.box without hive_flutter import')
            if 'AudioProcessingState' in content and 'case AudioProcessingState.completed' not in content and 'case AudioProcessingState.loading' not in content:
                errors.append(f'{f}: missing switch case in AudioProcessingState')
            if 'class AppDatabase' in content and 'LazyDatabase' not in content and 'sqflite' not in content:
                pass
        except Exception:
            errors.append(f'{f}: {e}')

    return errors

if __name__ == '__main__':
    d = '/home/z/my-project/quran-hadith-app/lib'
    for line in check_directory(d):
        print(line)
    print(f'\nTotal: {len(errors)} errors found')
    for e in errors[:50]:
        print(f'  {e}')
    if len(errors) > 50:
        print(f'  ... and {len(errors)-50} more')
