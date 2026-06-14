class PaymentModel {
  final String id;
  final String rentalId;
  final double amount;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime? paymentDate;

  PaymentModel({
    required this.id,
    required this.rentalId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentStatus,
    this.paymentDate,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? '',
      rentalId: json['rental_id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      paymentDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rental_id': rentalId,
      'amount': amount,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
    };
  }
}
