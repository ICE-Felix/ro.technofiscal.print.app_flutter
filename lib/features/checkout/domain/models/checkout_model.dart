import 'package:equatable/equatable.dart';
import 'billing_address_model.dart';
import 'shipping_address_model.dart';
import 'payment_method_model.dart';

class CheckoutModel extends Equatable {
  final BillingAddressModel billing;
  final ShippingAddressModel shipping;
  final bool billingSameAsShipping;
  final String lastDateModified;
  final PaymentMethodModel? selectedPaymentMethod;

  const CheckoutModel({
    required this.billing,
    required this.shipping,
    this.billingSameAsShipping = false,
    required this.lastDateModified,
    this.selectedPaymentMethod,
  });

  factory CheckoutModel.empty() {
    return CheckoutModel(
      billing: BillingAddressModel.empty(),
      shipping: ShippingAddressModel.empty(),
      billingSameAsShipping: false,
      lastDateModified: DateTime.now().toIso8601String(),
    );
  }

  factory CheckoutModel.fromJson(Map<String, dynamic> json) {
    return CheckoutModel(
      billing: BillingAddressModel.fromJson(json['billing'] ?? {}),
      shipping: ShippingAddressModel.fromJson(json['shipping'] ?? {}),
      billingSameAsShipping: json['billing_same_as_shipping'] ?? false,
      lastDateModified:
          json['last_date_modified'] ?? DateTime.now().toIso8601String(),
      selectedPaymentMethod: json['selected_payment_method'] != null
          ? PaymentMethodModel.fromJson(json['selected_payment_method'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'billing': billing.toJson(),
      'shipping': shipping.toJson(),
      'billing_same_as_shipping': billingSameAsShipping,
      'last_date_modified': lastDateModified,
      'selected_payment_method': selectedPaymentMethod?.toJson(),
    };
  }

  CheckoutModel copyWith({
    BillingAddressModel? billing,
    ShippingAddressModel? shipping,
    PaymentMethodModel? selectedPaymentMethod,
    bool? billingSameAsShipping,
    String? lastDateModified,
  }) {
    return CheckoutModel(
      billing: billing ?? this.billing,
      shipping: shipping ?? this.shipping,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
      billingSameAsShipping:
          billingSameAsShipping ?? this.billingSameAsShipping,
      lastDateModified: lastDateModified ?? DateTime.now().toIso8601String(),
    );
  }

  CheckoutModel updateBillingSameAsShipping(bool value) {
    if (value) {
      // Copy shipping data to billing (address fields only, not email/phone since they're in shipping)
      final updatedBilling = billing.copyWith(
        firstName: shipping.firstName,
        lastName: shipping.lastName,
        address1: shipping.address1,
        city: shipping.city,
        state: shipping.state,
        postcode: shipping.postcode,
        country: shipping.country,
      );

      return copyWith(billing: updatedBilling, billingSameAsShipping: value);
    } else {
      return copyWith(billingSameAsShipping: value);
    }
  }

  bool get isComplete {
    return billing.isComplete && shipping.isComplete && selectedPaymentMethod != null;
  }

  bool get hasValidAddresses {
    return billing.isComplete && shipping.isComplete;
  }

  @override
  List<Object?> get props => [
    billing,
    shipping,
    billingSameAsShipping,
    lastDateModified,
    selectedPaymentMethod,
  ];
}
