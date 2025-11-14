import 'package:equatable/equatable.dart';
import 'address_model.dart';

enum EntityType {
  individual,
  company;

  String get displayName {
    switch (this) {
      case EntityType.individual:
        return 'Individual Person';
      case EntityType.company:
        return 'Company / Legal Entity';
    }
  }
}

class PartyModel extends Equatable {
  final EntityType entityType;
  final String fullName;
  final String cnp; // Personal Numeric Code or CUI for companies
  final String idSeries;
  final String idNumber;
  final AddressModel address;
  final String phone;
  final String email;

  const PartyModel({
    this.entityType = EntityType.individual,
    this.fullName = '',
    this.cnp = '',
    this.idSeries = '',
    this.idNumber = '',
    required this.address,
    this.phone = '',
    this.email = '',
  });

  bool get isValid {
    if (entityType == EntityType.individual) {
      return fullName.isNotEmpty &&
          cnp.isNotEmpty &&
          idSeries.isNotEmpty &&
          idNumber.isNotEmpty &&
          address.isValid &&
          phone.isNotEmpty;
    } else {
      // For companies, CNP becomes CUI
      return fullName.isNotEmpty &&
          cnp.isNotEmpty &&
          address.isValid &&
          phone.isNotEmpty;
    }
  }

  factory PartyModel.empty() => PartyModel(
        address: AddressModel.empty(),
      );

  PartyModel copyWith({
    EntityType? entityType,
    String? fullName,
    String? cnp,
    String? idSeries,
    String? idNumber,
    AddressModel? address,
    String? phone,
    String? email,
  }) {
    return PartyModel(
      entityType: entityType ?? this.entityType,
      fullName: fullName ?? this.fullName,
      cnp: cnp ?? this.cnp,
      idSeries: idSeries ?? this.idSeries,
      idNumber: idNumber ?? this.idNumber,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entityType': entityType.name,
      'fullName': fullName,
      'cnp': cnp,
      'idSeries': idSeries,
      'idNumber': idNumber,
      'address': address.toJson(),
      'phone': phone,
      'email': email,
    };
  }

  factory PartyModel.fromJson(Map<String, dynamic> json) {
    return PartyModel(
      entityType: EntityType.values.firstWhere(
        (e) => e.name == json['entityType'],
        orElse: () => EntityType.individual,
      ),
      fullName: json['fullName'] ?? '',
      cnp: json['cnp'] ?? '',
      idSeries: json['idSeries'] ?? '',
      idNumber: json['idNumber'] ?? '',
      address: AddressModel.fromJson(json['address'] ?? {}),
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
    );
  }

  @override
  List<Object?> get props => [
        entityType,
        fullName,
        cnp,
        idSeries,
        idNumber,
        address,
        phone,
        email,
      ];
}
