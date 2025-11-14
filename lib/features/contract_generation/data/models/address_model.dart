import 'package:equatable/equatable.dart';

class AddressModel extends Equatable {
  final String country;
  final String county;
  final String city;
  final String postalCode;
  final String street;
  final String streetNumber;

  const AddressModel({
    this.country = 'Romania',
    this.county = '',
    this.city = '',
    this.postalCode = '',
    this.street = '',
    this.streetNumber = '',
  });

  bool get isValid {
    return country.isNotEmpty &&
        county.isNotEmpty &&
        city.isNotEmpty &&
        street.isNotEmpty &&
        streetNumber.isNotEmpty;
  }

  factory AddressModel.empty() => const AddressModel();

  AddressModel copyWith({
    String? country,
    String? county,
    String? city,
    String? postalCode,
    String? street,
    String? streetNumber,
  }) {
    return AddressModel(
      country: country ?? this.country,
      county: county ?? this.county,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      street: street ?? this.street,
      streetNumber: streetNumber ?? this.streetNumber,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'county': county,
      'city': city,
      'postalCode': postalCode,
      'street': street,
      'streetNumber': streetNumber,
    };
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      country: json['country'] ?? 'Romania',
      county: json['county'] ?? '',
      city: json['city'] ?? '',
      postalCode: json['postalCode'] ?? '',
      street: json['street'] ?? '',
      streetNumber: json['streetNumber'] ?? '',
    );
  }

  @override
  List<Object?> get props => [country, county, city, postalCode, street, streetNumber];
}
