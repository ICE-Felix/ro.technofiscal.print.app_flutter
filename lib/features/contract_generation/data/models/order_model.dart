import 'package:equatable/equatable.dart';

enum PaymentMethod {
  card,
  cash,
}

class OrderModel extends Equatable {
  final int numberOfCopies;
  final double printingFeePerCopy;
  final double serviceFee;
  final PaymentMethod paymentMethod;
  final bool termsAccepted;
  final int numberOfPages;
  final String contractType;

  const OrderModel({
    this.numberOfCopies = 2,
    this.printingFeePerCopy = 2.5,
    this.serviceFee = 10.0,
    this.paymentMethod = PaymentMethod.card,
    this.termsAccepted = false,
    this.numberOfPages = 4,
    this.contractType = 'Vehicle Sale Contract',
  });

  double get printingFee => numberOfCopies * printingFeePerCopy;
  double get totalCost => printingFee + serviceFee;

  OrderModel copyWith({
    int? numberOfCopies,
    double? printingFeePerCopy,
    double? serviceFee,
    PaymentMethod? paymentMethod,
    bool? termsAccepted,
    int? numberOfPages,
    String? contractType,
  }) {
    return OrderModel(
      numberOfCopies: numberOfCopies ?? this.numberOfCopies,
      printingFeePerCopy: printingFeePerCopy ?? this.printingFeePerCopy,
      serviceFee: serviceFee ?? this.serviceFee,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      numberOfPages: numberOfPages ?? this.numberOfPages,
      contractType: contractType ?? this.contractType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numberOfCopies': numberOfCopies,
      'printingFeePerCopy': printingFeePerCopy,
      'serviceFee': serviceFee,
      'paymentMethod': paymentMethod.name,
      'termsAccepted': termsAccepted,
      'numberOfPages': numberOfPages,
      'contractType': contractType,
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      numberOfCopies: json['numberOfCopies'] ?? 2,
      printingFeePerCopy: (json['printingFeePerCopy'] ?? 2.5).toDouble(),
      serviceFee: (json['serviceFee'] ?? 10.0).toDouble(),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == json['paymentMethod'],
        orElse: () => PaymentMethod.card,
      ),
      termsAccepted: json['termsAccepted'] ?? false,
      numberOfPages: json['numberOfPages'] ?? 4,
      contractType: json['contractType'] ?? 'Vehicle Sale Contract',
    );
  }

  @override
  List<Object?> get props => [
        numberOfCopies,
        printingFeePerCopy,
        serviceFee,
        paymentMethod,
        termsAccepted,
        numberOfPages,
        contractType,
      ];
}
