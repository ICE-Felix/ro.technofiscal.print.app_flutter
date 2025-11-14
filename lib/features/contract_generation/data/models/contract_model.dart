import 'package:equatable/equatable.dart';
import 'party_model.dart';

class ContractModel extends Equatable {
  final PartyModel seller;
  final PartyModel buyer;
  final String objectDetails;
  final String contractDetails;
  final double price;
  final DateTime? createdAt;
  final bool isComplete;

  const ContractModel({
    required this.seller,
    required this.buyer,
    this.objectDetails = '',
    this.contractDetails = '',
    this.price = 0.0,
    this.createdAt,
    this.isComplete = false,
  });

  factory ContractModel.empty() => ContractModel(
        seller: PartyModel.empty(),
        buyer: PartyModel.empty(),
        createdAt: DateTime.now(),
      );

  bool get canProceedFromSeller => seller.isValid;
  bool get canProceedFromBuyer => seller.isValid && buyer.isValid;
  bool get canProceedFromObjectDetails =>
      seller.isValid && buyer.isValid && objectDetails.isNotEmpty;
  bool get canSubmit =>
      seller.isValid &&
      buyer.isValid &&
      objectDetails.isNotEmpty &&
      contractDetails.isNotEmpty &&
      price > 0;

  ContractModel copyWith({
    PartyModel? seller,
    PartyModel? buyer,
    String? objectDetails,
    String? contractDetails,
    double? price,
    DateTime? createdAt,
    bool? isComplete,
  }) {
    return ContractModel(
      seller: seller ?? this.seller,
      buyer: buyer ?? this.buyer,
      objectDetails: objectDetails ?? this.objectDetails,
      contractDetails: contractDetails ?? this.contractDetails,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seller': seller.toJson(),
      'buyer': buyer.toJson(),
      'objectDetails': objectDetails,
      'contractDetails': contractDetails,
      'price': price,
      'createdAt': createdAt?.toIso8601String(),
      'isComplete': isComplete,
    };
  }

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    return ContractModel(
      seller: PartyModel.fromJson(json['seller'] ?? {}),
      buyer: PartyModel.fromJson(json['buyer'] ?? {}),
      objectDetails: json['objectDetails'] ?? '',
      contractDetails: json['contractDetails'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      isComplete: json['isComplete'] ?? false,
    );
  }

  @override
  List<Object?> get props => [
        seller,
        buyer,
        objectDetails,
        contractDetails,
        price,
        createdAt,
        isComplete,
      ];
}
