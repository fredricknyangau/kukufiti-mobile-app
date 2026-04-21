import 'package:mobile/core/models/broiler_models.dart';

const List<Map<String, dynamic>> expenseCategories = [
  {'value': 'feed', 'label': 'Feed'},
  {'value': 'medicine', 'label': 'Medicine & Vaccines'},
  {'value': 'equipment', 'label': 'Equipment'},
  {'value': 'transport', 'label': 'Transport'},
  {'value': 'utilities', 'label': 'Utilities'},
  {'value': 'labor', 'label': 'Labor'},
  {'value': 'water', 'label': 'Water'},
  {'value': 'electricity', 'label': 'Electricity'},
  {'value': 'other', 'label': 'Other'},
];

const List<Map<String, dynamic>> feedTypes = [
  {'value': 'starter', 'label': 'Starter (0-2 weeks)'},
  {'value': 'grower', 'label': 'Grower (2-4 weeks)'},
  {'value': 'finisher', 'label': 'Finisher (4+ weeks)'},
];

const List<Map<String, dynamic>> vaccinationMethods = [
  {'value': 'drinking_water', 'label': 'Drinking Water'},
  {'value': 'eye_drop', 'label': 'Eye Drop'},
  {'value': 'injection', 'label': 'Injection'},
  {'value': 'spray', 'label': 'Spray'},
];

// Common vaccines used in Kenya with schedules
const List<Map<String, dynamic>> vaccinationSchedule = [
  {'name': "Marek's Disease", 'dayOfAge': 1, 'method': 'injection'},
  {'name': 'Newcastle Disease (Hitchner B1)', 'dayOfAge': 7, 'method': 'eye_drop'},
  {'name': 'Infectious Bursal Disease (Gumboro) - First', 'dayOfAge': 14, 'method': 'drinking_water'},
  {'name': 'Newcastle Disease (Lasota)', 'dayOfAge': 18, 'method': 'drinking_water'},
  {'name': 'Infectious Bursal Disease (Gumboro) - Booster', 'dayOfAge': 21, 'method': 'drinking_water'},
  {'name': 'Newcastle Disease (Komarov)', 'dayOfAge': 28, 'method': 'drinking_water'},
  {'name': 'Fowl Pox', 'dayOfAge': 35, 'method': 'spray'},
];

const List<String> commonVaccines = [
  'Newcastle Disease (Lasota)',
  'Newcastle Disease (Hitchner B1)',
  'Newcastle Disease (Komarov)',
  'Infectious Bursal Disease (Gumboro)',
  'Fowl Pox',
  "Marek's Disease",
  'Infectious Bronchitis',
  'Fowl Typhoid',
  'Coccidiosis',
  'Deworming',
  'Other',
];

// Common broiler breeds in Kenya
const List<Map<String, String>> broilerBreeds = [
  {'value': 'ross_308', 'label': 'Ross 308'},
  {'value': 'cobb_500', 'label': 'Cobb 500'},
  {'value': 'arbor_acres', 'label': 'Arbor Acres'},
  {'value': 'hubbard', 'label': 'Hubbard'},
  {'value': 'kuroiler', 'label': 'Kuroiler'},
  {'value': 'sasso', 'label': 'Sasso'},
  {'value': 'other', 'label': 'Other'},
];

/// Breeds that have valid weight growth curves defined in [breedWeightStandards].
/// Used to prevent null-errors in charts/comparisons.
final List<Map<String, String>> breedsWithWeightStandards = broilerBreeds
    .where((b) => breedWeightStandards.containsKey(b['value']) || b['value'] == 'other')
    .toList();

// Standard weight curves for breeds (in grams per day of age)
const Map<String, List<Map<String, dynamic>>> breedWeightStandards = {
  'ross_308': [
    {'day': 0, 'weight': 42},
    {'day': 7, 'weight': 195},
    {'day': 14, 'weight': 485},
    {'day': 21, 'weight': 925},
    {'day': 28, 'weight': 1480},
    {'day': 35, 'weight': 2117},
    {'day': 42, 'weight': 2800},
    {'day': 49, 'weight': 3450},
  ],
  'cobb_500': [
    {'day': 0, 'weight': 40},
    {'day': 7, 'weight': 187},
    {'day': 14, 'weight': 461},
    {'day': 21, 'weight': 882},
    {'day': 28, 'weight': 1418},
    {'day': 35, 'weight': 2020},
    {'day': 42, 'weight': 2657},
    {'day': 49, 'weight': 3290},
  ],
  'arbor_acres': [
    {'day': 0, 'weight': 42},
    {'day': 7, 'weight': 180},
    {'day': 14, 'weight': 450},
    {'day': 21, 'weight': 870},
    {'day': 28, 'weight': 1400},
    {'day': 35, 'weight': 2000},
    {'day': 42, 'weight': 2600},
    {'day': 49, 'weight': 3200},
  ],
  'hubbard': [
    {'day': 0, 'weight': 41},
    {'day': 7, 'weight': 182},
    {'day': 14, 'weight': 455},
    {'day': 21, 'weight': 890},
    {'day': 28, 'weight': 1420},
    {'day': 35, 'weight': 1980},
    {'day': 42, 'weight': 2550},
    {'day': 49, 'weight': 3150},
  ],
  'kuroiler': [
    {'day': 0, 'weight': 38},
    {'day': 7, 'weight': 120},
    {'day': 14, 'weight': 280},
    {'day': 21, 'weight': 480},
    {'day': 28, 'weight': 750},
    {'day': 35, 'weight': 1100},
    {'day': 42, 'weight': 1450},
    {'day': 49, 'weight': 1800},
  ],
  'sasso': [
    {'day': 0, 'weight': 37},
    {'day': 7, 'weight': 115},
    {'day': 14, 'weight': 270},
    {'day': 21, 'weight': 460},
    {'day': 28, 'weight': 720},
    {'day': 35, 'weight': 1050},
    {'day': 42, 'weight': 1400},
    {'day': 49, 'weight': 1750},
  ],
  'other': [
    {'day': 0, 'weight': 40},
    {'day': 7, 'weight': 180},
    {'day': 14, 'weight': 450},
    {'day': 21, 'weight': 870},
    {'day': 28, 'weight': 1400},
    {'day': 35, 'weight': 2000},
    {'day': 42, 'weight': 2650},
    {'day': 49, 'weight': 3300},
  ],
};

// Local feed ingredients available in Kenya
final List<FeedIngredient> localFeedIngredients = [
  FeedIngredient(name: 'Whole Maize', quantity: 0, cost: 0, proteinContent: 9, energyContent: 3350),
  FeedIngredient(name: 'Maize Germ', quantity: 0, cost: 0, proteinContent: 10, energyContent: 3200),
  FeedIngredient(name: 'Maize Bran (Ngano)', quantity: 0, cost: 0, proteinContent: 10, energyContent: 2800),
  FeedIngredient(name: 'Wheat Bran', quantity: 0, cost: 0, proteinContent: 15, energyContent: 2600),
  FeedIngredient(name: 'Wheat Pollard', quantity: 0, cost: 0, proteinContent: 16, energyContent: 2700),
  FeedIngredient(name: 'Soybean Meal', quantity: 0, cost: 0, proteinContent: 44, energyContent: 2440),
  FeedIngredient(name: 'Sunflower Cake', quantity: 0, cost: 0, proteinContent: 32, energyContent: 2100),
  FeedIngredient(name: 'Cotton Seed Cake', quantity: 0, cost: 0, proteinContent: 38, energyContent: 2200),
  FeedIngredient(name: 'Fish Meal (Omena)', quantity: 0, cost: 0, proteinContent: 60, energyContent: 2800),
  FeedIngredient(name: 'Blood Meal', quantity: 0, cost: 0, proteinContent: 85, energyContent: 2800),
  FeedIngredient(name: 'Bone Meal', quantity: 0, cost: 0, proteinContent: 50, energyContent: 1000),
  FeedIngredient(name: 'DCP (Dicalcium Phosphate)', quantity: 0, cost: 0, proteinContent: 0, energyContent: 0),
  FeedIngredient(name: 'Limestone', quantity: 0, cost: 0, proteinContent: 0, energyContent: 0),
  FeedIngredient(name: 'Salt', quantity: 0, cost: 0, proteinContent: 0, energyContent: 0),
  FeedIngredient(name: 'Premix (Vitamins & Minerals)', quantity: 0, cost: 0, proteinContent: 0, energyContent: 0),
];

// Feed formulation targets
const Map<String, Map<String, double>> feedRequirements = {
  'starter': {'protein': 23, 'energy': 3000},
  'grower': {'protein': 20, 'energy': 3100},
  'finisher': {'protein': 18, 'energy': 3200},
};

// Biosecurity checklist items
const List<String> biosecurityChecklist = [
  'Footbath disinfectant changed/refreshed',
  'Visitor log completed and signed',
  'All equipment sanitized before use',
  'Feed storage area checked for contamination',
  'Water containers cleaned and refilled',
  'Dead birds removed and properly disposed',
  'Rodent/pest control measures checked',
  'Farm perimeter secured',
  'Personal protective equipment used',
  'Hand washing station maintained',
];

// Kenyan counties for market prices
const List<String> kenyanCounties = [
  'Nairobi',
  'Mombasa',
  'Kisumu',
  'Nakuru',
  'Eldoret',
  'Thika',
  'Machakos',
  'Kiambu',
  'Nyeri',
  'Meru',
  'Embu',
  'Kakamega',
  'Bungoma',
  'Kericho',
  'Naivasha',
];

// Common chick suppliers in Kenya
const List<String> chickSuppliers = [
  'Kenchic',
  'Muguku Poultry Farm',
  'Sigma Feeds',
  'Bora Poultry',
  'Kukuchic',
  'Other',
];
