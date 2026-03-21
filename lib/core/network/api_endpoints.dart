class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';   // backend: POST /auth/register
  static const String profile = '/auth/me';           // backend: GET /auth/me

  // Batches (backend uses /flocks/)
  static const String batches = '/flocks/';
  static String batchDetails(String id) => '/flocks/$id';

  // Events (Health/Growth)
  static const String mortality = '/events/mortality';
  static const String feed = '/events/feed';
  static const String vaccination = '/events/vaccination';
  static const String weight = '/events/weight';

  // Financials — NOTE: backend prefixes these under /finance/
  static const String expenditures = '/finance/expenditures';
  static const String sales = '/finance/sales';
  static const String inventory = '/inventory/';

  // Vet / Health
  static const String vetConsultations = '/health/consultations';

  // Market
  static const String marketPrices = '/market/prices';

  // Other
  static const String biosecurity = '/biosecurity/';
  static const String alerts = '/alerts/';
  static const String auditLogs = '/admin/audit-logs';
  static String people(String type) => '/people/$type';

  // Analytics
  static const String dashboardMetrics = '/analytics/dashboard-metrics';
  static const String financialChart = '/analytics/charts/revenue-vs-expenses';

  // Admin
  static const String adminStats = '/admin/stats';
  static const String adminTransactions = '/admin/transactions';

  // Billing
  static const String mySubscription = '/billing/my-subscription';
  static const String subscribe = '/billing/subscribe';
  static const String plans = '/billing/plans';

  // New: Backend Sync
  static const String resources = '/resources/';
  static const String settings = '/settings/';
  static const String tasks = '/tasks/';
  static const String farms = '/farms/';

  // AI Advisory
  static const String aiFeedRecommendation = '/ai/feed-recommendation';
  static const String aiMortalityAnalysis = '/ai/mortality-analysis';
  static const String aiHarvestPrediction = '/ai/harvest-prediction';
  static const String aiDiseaseRisk = '/ai/disease-risk';
  static const String aiFcrInsights = '/ai/fcr-insights';
  static const String aiChat = '/ai/chat';
}


