import 'package:app/core/service_locator.dart';
import 'package:app/features/cart/domain/repositories/cart_repository.dart';
import 'package:app/features/checkout/domain/models/checkout_model.dart';
import 'package:app/features/checkout/domain/models/billing_address_model.dart';
import 'package:app/features/checkout/domain/models/shipping_address_model.dart';
import 'package:app/features/checkout/domain/models/payment_method_model.dart';
import 'package:app/features/checkout/domain/place_order_usecase.dart';
import 'package:app/features/checkout/domain/repository/order_repository.dart';
import 'package:app/features/checkout/domain/service/checkout_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit() : super(CheckoutState(checkout: CheckoutModel.empty()));

  Future<void> loadCheckout() async {
    emit(state.copyWith(isLoading: true, isError: false, message: ''));

    try {
      final checkout = await sl.get<CheckoutService>().getCheckout();
      emit(state.copyWith(checkout: checkout, isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          isError: true,
          message: 'Failed to load checkout data: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> resetCheckout() async {
    final checkout = await sl.get<CheckoutService>().getCheckout();
    if (checkout != null) {
      emit(CheckoutState(checkout: checkout, isLoading: false));
    } else {
      emit(CheckoutState(checkout: CheckoutModel.empty()));
    }
  }

  Future<void> updateBilling(BillingAddressModel billing) async {
    try {
      final updatedCheckout = state.checkout.copyWith(billing: billing);
      emit(state.copyWith(checkout: updatedCheckout));
    } catch (e) {
      emit(
        state.copyWith(
          isError: true,
          message: 'Failed to update billing address: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> updateShipping(ShippingAddressModel shipping) async {
    try {
      final updatedCheckout = state.checkout.copyWith(shipping: shipping);
      emit(state.copyWith(checkout: updatedCheckout));
    } catch (e) {
      emit(
        state.copyWith(
          isError: true,
          message: 'Failed to update shipping address: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> updatePaymentMethod(PaymentMethodModel paymentMethod) async {
    try {
      final updatedCheckout = state.checkout.copyWith(
        selectedPaymentMethod: paymentMethod,
      );
      emit(state.copyWith(checkout: updatedCheckout));
    } catch (e) {
      emit(
        state.copyWith(
          isError: true,
          message: 'Failed to update payment method: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> updateBillingSameAsShipping(bool value) async {
    try {
      final updatedCheckout = state.checkout.updateBillingSameAsShipping(value);
      emit(state.copyWith(checkout: updatedCheckout));
    } catch (e) {
      emit(
        state.copyWith(
          isError: true,
          message: 'Failed to update billing same as shipping: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> clearCheckout() async {
    emit(state.copyWith(isLoading: true, isError: false, message: ''));

    try {
      emit(
        state.copyWith(
          checkout: CheckoutModel.empty(),
          isLoading: false,
          message: 'Checkout cleared successfully',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          isError: true,
          message: 'Failed to clear checkout: ${e.toString()}',
        ),
      );
    }
  }

  void clearError() {
    emit(state.copyWith(isError: false, message: ''));
  }

  Future<void> placeOrder() async {
    emit(state.copyWith(isLoading: true, isError: false, message: ''));

    try {
      final cart = await sl.get<CartRepository>().getCart();

      final result = await PlaceOrderUsecase(
        orderRepository: sl.get<OrderRepository>(),
      ).call(
        OrderParams(
          billingFirstName: state.checkout.billing.firstName,
          billingLastName: state.checkout.billing.lastName,
          billingAddress1: state.checkout.billing.address1,
          billingCity: state.checkout.billing.city,
          billingState: state.checkout.billing.state,
          billingPostcode: state.checkout.billing.postcode,
          billingCountry: state.checkout.billing.country,
          billingEmail: state.checkout.shipping.email,
          billingPhone: state.checkout.shipping.phone,
          shippingFirstName: state.checkout.shipping.firstName,
          shippingLastName: state.checkout.shipping.lastName,
          shippingAddress1: state.checkout.shipping.address1,
          shippingCity: state.checkout.shipping.city,
          shippingState: state.checkout.shipping.state,
          shippingPostcode: state.checkout.shipping.postcode,
          shippingCountry: state.checkout.shipping.country,
          lineItems: cart.items,
          paymentMethod: state.checkout.selectedPaymentMethod?.id ?? '',
          paymentMethodTitle: state.checkout.selectedPaymentMethod?.name ?? '',
        ),
      );
      sl.get<CheckoutService>().saveInfo(state.checkout);
      emit(
        state.copyWith(
          isLoading: false,
          isError: false,
          isPayReady: true,
          redirectUrl: result,
          closeCheckout: true,
          message: 'Order placed successfully! Order ID: $result',
        ),
      );
    } catch (e, str) {
      emit(
        state.copyWith(
          isLoading: false,
          isError: true,
          message: 'Failed to place order: ${e.toString()}',
        ),
      );
    }
  }
}
