import os

base = "/home/ubuntu/Projects/kuku-fiti-project/mobile/lib/features"
files = [
    "admin_dashboard_management/presentation/screens/admin_dashboard_screen.dart",
    "audit_logs_management/presentation/screens/audit_logs_screen.dart",
    "calendar_management/presentation/screens/calendar_screen.dart",
    "market_management/presentation/screens/market_screen.dart",
    "profile_management/presentation/screens/profile_screen.dart",
    "reports_management/presentation/screens/reports_screen.dart",
    "resources_management/presentation/screens/resources_screen.dart",
]

print("Fixing imports...")
for f in files:
    path = os.path.join(base, f)
    if os.path.exists(path):
        with open(path, 'r') as f_in:
            content = f_in.read()
        
        # 1. Widgets
        content = content.replace("../../widgets/", "../../../../presentation/widgets/")
        # 2. Providers
        content = content.replace("../../../providers/", "../../../../providers/")
        # 3. Core
        content = content.replace("../../../core/", "../../../../core/")
        
        with open(path, 'w') as f_out:
            f_out.write(content)
        print(f"Fixed: {f}")

print("All fixes applied.")
