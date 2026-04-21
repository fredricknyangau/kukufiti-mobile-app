import 'package:mobile/features/expenses_management/domain/entities/expense.dart';

class ExpenseDto {
  final String id;
  final String category;
  final double amount;
  final String description;
  final DateTime date;

  ExpenseDto({
    required this.id,
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
  });

  factory ExpenseDto.fromJson(Map<String, dynamic> json) {
    return ExpenseDto(
      id: json['id']?.toString() ?? '',
      category: json['category'] ?? 'Other',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? 'No description',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Expense toEntity() {
    return Expense(
      id: id,
      category: category,
      amount: amount,
      description: description,
      date: date,
    );
  }
}
