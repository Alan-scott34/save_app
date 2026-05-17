import pathlib
import re
root = pathlib.Path('lib')
patterns = [
    (re.compile(r'import \"\.\./config/app_theme.dart\";'), 'import "app_theme.dart";'),
    (re.compile(r'import \"\.\./utils/constants.dart\";'), 'import "constants.dart";'),
    (re.compile(r'import \"\.\./models/app_models.dart\";'), 'import "app_models.dart";'),
    (re.compile(r'import \"\.\./services/transaction_service.dart\";'), 'import "transaction_service.dart";'),
    (re.compile(r'import \"\.\./services/goal_service.dart\";'), 'import "goal_service.dart";'),
    (re.compile(r'import \"\.\./services/auth_service.dart\";'), 'import "auth_service.dart";'),
    (re.compile(r'import \"\.\./screens/([^\"]+)\.dart\";'), r'import "\1.dart";'),
    (re.compile(r'import \"utils/constants.dart\";'), 'import "constants.dart";'),
]
for path in root.rglob('*.dart'):
    text = path.read_text(encoding='utf-8')
    new = text
    for pat, repl in patterns:
        new = pat.sub(repl, new)
    if new != text:
        path.write_text(new, encoding='utf-8')
        print(f'Updated {path}')
