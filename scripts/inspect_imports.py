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

for f in files:
    path = os.path.join(base, f)
    if os.path.exists(path):
        print(f"\n--- {f} ---")
        with open(path, 'r') as f_in:
            for line in f_in:
                if line.strip().startswith("import '") and "package:" not in line:
                    print(line.strip())
