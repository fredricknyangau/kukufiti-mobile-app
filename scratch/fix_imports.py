import os
import re

patterns = [
    (r"import '.*presentation/widgets/custom_card\.dart';", "import 'package:mobile/shared/widgets/custom_card.dart';"),
    (r"import '.*presentation/widgets/custom_input\.dart';", "import 'package:mobile/shared/widgets/custom_input.dart';"),
    (r"import 'package:mobile/presentation/widgets/custom_card\.dart';", "import 'package:mobile/shared/widgets/custom_card.dart';"),
    (r"import '.*presentation/widgets/custom_button\.dart';", "import 'package:mobile/shared/widgets/custom_button.dart';"),
    (r"import '.*presentation/widgets/app_drawer\.dart';", "import 'package:mobile/shared/widgets/app_drawer.dart';"),
]

def fix_file(path):
    with open(path, 'r') as f:
        content = f.read()
    
    original = content
    for pattern, replacement in patterns:
        content = re.sub(pattern, replacement, content)
    
    if content != original:
        with open(path, 'w') as f:
            f.write(content)
        print(f"Fixed {path}")

for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endsWith('.dart'):
            fix_file(os.path.join(root, file))
