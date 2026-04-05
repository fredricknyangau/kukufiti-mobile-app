/// data_providers.dart — barrel re-export file
///
/// This file previously contained all 453 lines of Riverpod providers.
/// Each domain has been extracted into its own file for maintainability.
/// Import this file for backward compatibility, or import individual
/// domain files directly in new code.
///
/// Domain files:
///   _provider_utils.dart  — shared fetchWithFallback, setupKeepAlive helpers
///   flock_providers.dart  — mortality, feed, vaccination, weight, daily checks
///   finance_providers.dart — sales, expenditures, inventory
///   billing_providers.dart — subscription, plan details
///   analytics_providers.dart — dashboard metrics, charts, benchmarks
///   user_providers.dart    — profile, farms
///   people_providers.dart  — suppliers, customers, employees
///   admin_providers.dart   — admin stats, transactions, users
///   task_providers.dart    — scheduled tasks with CRUD notifier
library;

export '_provider_utils.dart';
export 'flock_providers.dart';
export 'finance_providers.dart';
export 'billing_providers.dart';
export 'analytics_providers.dart';
export 'user_providers.dart';
export 'people_providers.dart';
export 'admin_providers.dart';
export 'task_providers.dart';
export 'alerts_providers.dart';
export 'biosecurity_providers.dart';
export 'resources_providers.dart';
export 'audit_logs_providers.dart';
export 'vet_providers.dart';
export 'market_providers.dart';
