class Sale {
  final String id;
  final double amount;
  final int quantity;
  final double pricePerBird;
  final String buyer;
  final DateTime date;

  Sale({
    required this.id,
    required this.amount,
    required this.quantity,
    required this.pricePerBird,
    required this.buyer,
    required this.date,
  });
}
