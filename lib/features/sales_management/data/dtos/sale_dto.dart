import '../../domain/entities/sale.dart';

class SaleDto {
  final String id;
  final double amount;
  final int quantity;
  final double pricePerBird;
  final String buyer;
  final DateTime date;

  SaleDto({
    required this.id,
    required this.amount,
    required this.quantity,
    required this.pricePerBird,
    required this.buyer,
    required this.date,
  });

  factory SaleDto.fromJson(Map<String, dynamic> json) {
    return SaleDto(
      id: json['id']?.toString() ?? '',
      amount: (json['total_amount'] as num?)?.toDouble() ?? 
              (json['amount'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 0,
      pricePerBird: (json['price_per_bird'] as num?)?.toDouble() ?? 0.0,
      buyer: json['buyer_name'] ?? json['buyer'] ?? 'Walk-in',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Sale toEntity() {
    return Sale(
      id: id,
      amount: amount,
      quantity: quantity,
      pricePerBird: pricePerBird,
      buyer: buyer,
      date: date,
    );
  }
}
